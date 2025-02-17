import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../account/account_cubit.dart';
import '../account/account_list_widget.dart';
import '../group/group_list_page.dart';
import '../account_edit/account_edit_page.dart';

import '../account_filter/account_filter_page.dart';
import '../models/secret_config.dart';
import '../setting/setting_cubit.dart';
import '../setting/setting_drawer.dart';
import '../l10n/l10n.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeView();
  }
}

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SettingCubit, SettingState, List<SecretConfig>>(
      selector: (state) {
        return state.secrets;
      },
      builder: (BuildContext context, _) {
        final l10n = context.l10n;
        return BlocBuilder<AccountCubit, AccountState>(
          builder: (context, state) {
            final colorScheme = Theme.of(context).colorScheme;
            return Scaffold(
              key: _scaffoldKey,
              floatingActionButton: state.status != AccountStatus.success
                  ? const CircularProgressIndicator.adaptive()
                  : FloatingActionButton(
                      foregroundColor: colorScheme.primary,
                      backgroundColor: colorScheme.primaryContainer,
                      shape: const CircleBorder(),
                      onPressed: () {
                        Navigator.of(context).push(
                          AccountEditPage.route(),
                        );
                      },
                      child: const Icon(Icons.add),
                    ),
              appBar: AppBar(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                centerTitle: true,
                title: Text(l10n.accountsHomeTitle),
                leading: IconButton(
                  icon: const Icon(Icons.grid_view_outlined),
                  onPressed: () {
                    Navigator.of(context).push(
                      GroupListPage.route(),
                    );
                  },
                ),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      context.read<AccountCubit>().setGroupID('null');
                      Navigator.of(context).push(
                        AccountFilterPage.route(),
                      );
                    },
                  ),
                  IconButton(
                    onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                    icon: const Icon(Icons.settings_outlined),
                  )
                ],
              ),
              body: AccountListWidget([...state.accounts]),
              drawer: const SettingDrawer(),
            );
          },
        );
      },
    );
  }
}
