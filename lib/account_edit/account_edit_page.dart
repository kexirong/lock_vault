import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../l10n/l10n.dart';

import '../account/account_cubit.dart';
import '../models/account.dart';
import '../setting/setting_cubit.dart';
import 'account_edit_cubit.dart';

class AccountEditPage extends StatelessWidget {
  const AccountEditPage({super.key});

  static Route<void> route({PlainAccount? account}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => AccountEditCubit(
          account: account,
        ),
        child: const AccountEditPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AccountCubit, AccountState>(
          listenWhen: (previous, current) =>
              previous.status == AccountStatus.loading && current.status == AccountStatus.success,
          listener: (context, state) => context.read<AccountEditCubit>().onSuccess(),
        ),
        BlocListener<AccountEditCubit, AccountEditState>(
            listenWhen: (previous, current) =>
                previous.status != current.status && current.status == AccountEditStatus.success,
            listener: (context, state) => Navigator.of(context).pop()),
      ],
      child: AccountEditView(),
    );
  }
}

class AccountEditView extends StatelessWidget {
  AccountEditView({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AccountEditCubit>();
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(cubit.state.isEdit ? l10n.editAccountTitle : l10n.addAccountTitle),
      ),
      floatingActionButton: BlocSelector<AccountEditCubit, AccountEditState, AccountEditStatus>(
        selector: (state) => state.status,
        builder: (context, status) {
          return FloatingActionButton(
            shape: const ContinuousRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32)),
            ),
            onPressed: () async {
              if (status == AccountEditStatus.loading) return;
              if (!_formKey.currentState!.validate()) {
                return;
              }
              cubit.onSubmit();
              BaseAccount account = cubit.state.account;
              var mSecret = context.read<SettingCubit>().state.mainSecret;

              if (mSecret != null) {
                account = cubit.state.account.encrypt(mSecret);
              }
              if (cubit.state.isEdit) {
                await context.read<AccountCubit>().updateAccount(account);
              } else {
                await context.read<AccountCubit>().addAccount(account);
              }
            },
            child: status == AccountEditStatus.loading
                ? const CircularProgressIndicator.adaptive()
                : const Icon(Icons.check_rounded),
          );
        },
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Form(
                  key: _formKey,
                  child: const Column(
                    children: [
                      _TitleField(),
                      _UrlField(),
                      _GroupIDField(),
                      _UsernameField(),
                      _PasswordField(),
                      _ExtendField(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: OverflowBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    OutlinedButton(
                        onPressed: () {},
                        child: Text(
                          l10n.randPasswordButton,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        )),
                    OutlinedButton(
                      onPressed: () {
                        cubit.addExtendField();
                      },
                      child: Text(
                        l10n.addFieldButton,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

FormFieldValidator _notEmptyValidator(BuildContext context) {
  final l10n = context.l10n;
  return (value) {
    if (value == null || value.isEmpty) {
      return l10n.filledField;
    }
    return null;
  };
}

class _TitleField extends StatelessWidget {
  const _TitleField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final cubit = context.read<AccountEditCubit>();
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Text(l10n.accountTitle,
              style: const TextStyle(fontSize: 20), textAlign: TextAlign.end),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 4, left: 2),
          child: Text(':', style: TextStyle(fontSize: 20)),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            initialValue: cubit.state.account.title,
            decoration: const InputDecoration(
              // enabled: !state.status.isLoadingOrSuccess,
              border: UnderlineInputBorder(),
            ),
            onChanged: (value) {
              cubit.onEdit(cubit.state.account.copyWith(title: value));
            },
            validator: _notEmptyValidator(context),
          ),
        ),
      ],
    );
  }
}

class _UrlField extends StatelessWidget {
  const _UrlField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<AccountEditCubit>();
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child:
              Text(l10n.url, style: const TextStyle(fontSize: 20), textAlign: TextAlign.end),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 4, left: 2),
          child: Text(':', style: TextStyle(fontSize: 20)),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            initialValue: cubit.state.account.url,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
            ),
            onChanged: (value) {
              cubit.onEdit(cubit.state.account.copyWith(url: value));
            },
            validator: _notEmptyValidator(context),
          ),
        ),
      ],
    );
  }
}

class _GroupIDField extends StatelessWidget {
  const _GroupIDField();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AccountEditCubit>();
    final l10n = context.l10n;
    final accountCubit = context.read<AccountCubit>();
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Text(l10n.accountGroup, style: TextStyle(fontSize: 20), textAlign: TextAlign.end),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 4, left: 2),
          child: Text(':', style: TextStyle(fontSize: 20)),
        ),
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<String>(
            iconSize: 32,
            value: cubit.state.account.groupID,
            icon: const Icon(Icons.arrow_drop_down),
            onChanged: (String? value) {
              cubit.onEdit(cubit.state.account.copyWith(groupID: value));
            },
            items: <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(
                value: '',
                child: Text(l10n.defaultGroup),
              ),
              ...accountCubit.state.groups.map<DropdownMenuItem<String>>((group) {
                return DropdownMenuItem<String>(
                  value: group.id,
                  child: Text(
                    group.name,
                    textAlign: TextAlign.end,
                  ),
                );
              })
            ],
          ),
        ),
      ],
    );
  }
}

class _UsernameField extends StatelessWidget {
  const _UsernameField();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AccountEditCubit>();
    final l10n = context.l10n;
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child:
              Text(l10n.username, style: TextStyle(fontSize: 20), textAlign: TextAlign.end),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 4, left: 2),
          child: Text(':', style: TextStyle(fontSize: 20)),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            initialValue: cubit.state.account.username,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
            ),
            onChanged: (value) {
              cubit.onEdit(cubit.state.account.copyWith(username: value));
            },
            validator: _notEmptyValidator(context),
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AccountEditCubit>();
    final l10n = context.l10n;
    return Row(
      children: <Widget>[
        Expanded(
            flex: 1,
            child: Text(l10n.password,
                style: TextStyle(fontSize: 20), textAlign: TextAlign.end)),
        const Padding(
          padding: EdgeInsets.only(right: 4, left: 2),
          child: Text(':', style: TextStyle(fontSize: 20)),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            initialValue: cubit.state.account.password,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
            ),
            onChanged: (value) {
              cubit.onEdit(cubit.state.account.copyWith(password: value));
            },
            validator: _notEmptyValidator(context),
          ),
        ),
      ],
    );
  }
}

class _ExtendFieldItem {
  String name;
  String value;

  _ExtendFieldItem(this.name, this.value);
}

class _ExtendField extends StatelessWidget {
  const _ExtendField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<AccountEditCubit, AccountEditState>(builder: (context, state) {
      final extendFieldItems = <_ExtendFieldItem>[];
      state.account.extendField.forEach((k, v) {
        extendFieldItems.add(_ExtendFieldItem(k, v));
      });

      setExtendField() {
        final extendField = {for (var i in extendFieldItems) i.name: i.value};
        context.read<AccountEditCubit>().onEdit(state.account.copyWith(extendField: extendField));
      }

      final List<Widget> rows = [];
      if (extendFieldItems.isNotEmpty) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                const Expanded(child: Divider(height: 0)),
                Text(l10n.accountExtend),
                const Expanded(child: Divider(height: 0)),
              ],
            ),
          ),
        );

        for (var item in extendFieldItems) {
          rows.add(
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: item.name,
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    onChanged: (value) {
                      item.name = value;
                      setExtendField();
                    },
                    validator: _notEmptyValidator(context),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 4, left: 2),
                  child: Text(':', style: TextStyle(fontSize: 20)),
                ),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: item.value,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    onChanged: (value) {
                      item.value = value;
                      setExtendField();
                    },
                    validator: _notEmptyValidator(context),
                  ),
                ),
                GestureDetector(
                  child: Icon(
                    Icons.remove_circle_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onTap: () {
                    extendFieldItems.remove(item);
                    setExtendField();
                  },
                ),
              ],
            ),
          );
        }
      }
      return Column(children: rows);
    });
  }
}
