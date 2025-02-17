import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../l10n/l10n.dart';
import '../models/webdav_config.dart';
import '../setting/setting_cubit.dart';
import '../sync_webdav/sync_webdav_cubit.dart';
import 'setting_sync_cubit.dart';

class SettingSyncPage extends StatelessWidget {
  const SettingSyncPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => SettingSyncCubit(context.read<SettingCubit>().state.webdavConfig),
        child: const SettingSyncPage(),
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
        title: Text(l10n.syncTitle),
        centerTitle: true,
      ),
      body: const SettingSyncView(),
    );
  }
}

class SettingSyncView extends StatelessWidget {
  const SettingSyncView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return SingleChildScrollView(
      child: Column(
        children: [
          _SyncMethodForm(),
          ListTile(
            textColor: colorScheme.primary,
            title: Text(l10n.webdav),
          ),
          _WebdavConfigForm(),
          Card.filled(
            margin: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.read<SyncWebdavCubit>().sync();
                },
                child: Text(l10n.doSync),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _SyncMethodForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card.filled(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(child: Text(l10n.syncMethod)),
          BlocSelector<SettingCubit, SettingState, SyncMethod>(
            selector: (state) => state.syncMethod,
            builder: (context, syncMethod) {
              return DropdownButton<SyncMethod>(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                value: syncMethod,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                onChanged: (SyncMethod? value) async {
                  context.read<SettingCubit>().setSyncMethod(value ?? SyncMethod.off);
                },
                items: SyncMethod.values.map<DropdownMenuItem<SyncMethod>>((SyncMethod value) {
                  return DropdownMenuItem<SyncMethod>(
                    value: value,
                    child: Text(value.name),
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}

class _WebdavConfigForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final l10n = context.l10n;
    return Card.filled(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: BlocBuilder<SettingSyncCubit, SettingSyncState>(
          builder: (context, state) {
            return Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: state.webdavUrl,
                    decoration: InputDecoration(labelText: l10n.url),
                    onChanged: (value) {
                      context.read<SettingSyncCubit>().webdavUrlChanged(value);
                    },
                    validator: _notEmptyValidator(context),
                  ),
                  TextFormField(
                    initialValue: state.webdavUser,
                    decoration: InputDecoration(labelText: l10n.username),
                    onChanged: (value) {
                      context.read<SettingSyncCubit>().webdavUserChanged(value);
                    },
                    validator: _notEmptyValidator(context),
                  ),
                  TextFormField(
                    initialValue: state.webdavPassword,
                    decoration: InputDecoration(labelText: l10n.password),
                    onChanged: (value) {
                      context.read<SettingSyncCubit>().webdavPasswordChanged(value);
                    },
                    validator: _notEmptyValidator(context),
                  ),
                  TextFormField(
                    initialValue: state.webdavPath,
                    decoration: InputDecoration(labelText: l10n.webdavPath),
                    onChanged: (value) {
                      context.read<SettingSyncCubit>().webdavPathChanged(value);
                    },
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: OutlinedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                      },
                      child: Text(l10n.test),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        context.read<SettingCubit>().setWebdavConfig(
                              WebdavConfig(
                                url: state.webdavUrl,
                                user: state.webdavUser,
                                password: state.webdavPassword,
                                path: state.webdavPath,
                              ),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(l10n.saveSuccess),
                        ));
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

FormFieldValidator _notEmptyValidator(BuildContext context) {
  final l10n = context.l10n;
  return (value) {
    if (value == null || value.isEmpty) {
      return l10n.filledField;
    }
    return null;
  };
}
