import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lock_vault/account/account_cubit.dart';
import 'package:lock_vault/l10n/l10n.dart';
import '../models/account.dart';
import '../setting/setting_cubit.dart';
import 'setting_secret_cubit.dart';

class SettingSecretPage extends StatelessWidget {
  const SettingSecretPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => SettingSecretCubit(),
        child: const SettingSecretPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Text(l10n.settingSecretTitle),
        centerTitle: true,
      ),
      body: const SettingSecretView(),
    );
  }
}

class SettingSecretView extends StatelessWidget {
  const SettingSecretView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return BlocBuilder<SettingCubit, SettingState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                textColor: colorScheme.primary,
                title: Text(l10n.mainSecret),
              ),
              _SetMainSecret(),
              ListTile(
                textColor: colorScheme.primary,
                title: Text(l10n.attSecrets),
              ),
              _AttSecrets(),
              Card.filled(
                margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      if (state.mainSecret == null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(l10n.setMainSecret),
                        ));
                        return;
                      }

                      final accountCubit = context.read<AccountCubit>();
                      final accounts = [...accountCubit.state.accounts];
                      for (var account in accounts) {
                        if (account is EncryptAccount) {
                          //已加密数据重新加密
                          //使用当前主密钥加密的数据不处理
                          if (state.isMainSecret(account.mKey)) {
                            continue;
                          }
                          var secret = state.getSecret(account.mKey);
                          //跳过无法解密的数据
                          if (secret == null) continue;
                          account = account.decrypt(secret);
                        }
                        //使用主密钥进行加密
                        account = (account as PlainAccount).encrypt(state.mainSecret!);
                        await accountCubit.updateAccount(account);
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(l10n.reEncryptComplete),
                        ));
                      }
                    },
                    child: Text(l10n.reEncrypt),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class _SetMainSecret extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final l10n = context.l10n;
    return Card.filled(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: BlocBuilder<SettingSecretCubit, SettingSecretState>(
          builder: (context, state) {
            return Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(labelText: l10n.oldSecret),
                    validator: (value) {
                      final cubit = context.read<SettingCubit>();
                      var mSecret = cubit.state.mainSecret;
                      if (mSecret == null || mSecret.isEmpty) return null;
                      if (value == null || value.isEmpty) {
                        return l10n.inputOldSecret;
                      } else if (value != mSecret) {
                        return l10n.invalidOldSecret;
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(labelText: l10n.newSecret),
                    onChanged: (value) {
                      context.read<SettingSecretCubit>().newMainSecretChanged(value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.inputNewSecret;
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(labelText: l10n.newSecretConfirm),
                    onChanged: (value) {
                      context.read<SettingSecretCubit>().confirmNewMainSecretChanged(value);
                    },
                    validator: (value) {
                      if (value != state.newMainSecret) {
                        return l10n.notMatchNewSecret;
                      }
                      return null;
                    },
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 16),
                    child: OutlinedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        context.read<SettingCubit>().setMainSecret(state.newMainSecret);
                      },
                      child: Text(l10n.save),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ObscuredState extends Equatable {
  final bool isObscured;

  const ObscuredState({this.isObscured = true}); // 默认隐藏

  ObscuredState copyWith({bool? isObscured}) {
    return ObscuredState(isObscured: isObscured ?? this.isObscured);
  }

  @override
  List<Object?> get props => [isObscured];
}

class ObscuredCubit extends Cubit<ObscuredState> {
  ObscuredCubit() : super(const ObscuredState());

  void toggleObscured() {
    emit(state.copyWith(isObscured: !state.isObscured));
  }
}

class _AttSecrets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final attSecrets = context.read<SettingCubit>().state.attSecrets;
    return Card.filled(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          ListView.separated(
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(height: 0);
            },
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: attSecrets.length,
            itemBuilder: (BuildContext context, int index) {
              return BlocProvider(
                // 在需要使用的地方提供 Cubit
                create: (context) => ObscuredCubit(),
                child: BlocBuilder<ObscuredCubit, ObscuredState>(
                  builder: (context, state) {
                    return ListTile(
                      leading: GestureDetector(
                        child: Icon(
                          state.isObscured ? Icons.visibility_off : Icons.visibility,
                          color: colorScheme.secondary,
                        ),
                        onTap: () {
                          context.read<ObscuredCubit>().toggleObscured();
                        },
                      ),
                      title: Text(state.isObscured ? '*******' : attSecrets[index].secret),
                      trailing: GestureDetector(
                        onTap: () {
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Text(l10n.confirm),
                              content: Text(l10n.confirmContent),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context
                                        .read<SettingCubit>()
                                        .deleteSecret(attSecrets[index].secret);
                                    Navigator.pop(context);
                                  },
                                  child: Text(l10n.ok),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Icon(Icons.remove_circle_outline, color: colorScheme.error),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          attSecrets.isNotEmpty ? const Divider(height: 0) : const SizedBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                child:   Text(l10n.add),
                onPressed: () {
                  var inputSecret = '';
                  showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog.adaptive(
                      title:   Text( l10n.addAttSecret),
                      content: TextField(onChanged: (value) {
                        inputSecret = value;
                      }),
                      actions: <Widget>[
                        TextButton(
                          child:   Text(l10n.ok),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        TextButton(
                          child:   Text(l10n.cancel),
                          onPressed: () {
                            if (inputSecret.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(l10n.secretNotSecret),
                              ));
                              return;
                            }
                            context.read<SettingCubit>().addSecret(inputSecret.trim());
                            Navigator.pop(context, true);
                            //
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
