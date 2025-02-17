import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lock_vault/l10n/l10n.dart';

import '../account_filter/account_filter_page.dart';
import '../models/account_group.dart';
import '../group_edit/group_edit_page.dart';
import '../account/account_cubit.dart';

class GroupListPage extends StatelessWidget {
  const GroupListPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => GroupListPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        foregroundColor: colorScheme.primary,
        backgroundColor: colorScheme.primaryContainer,
        shape: const CircleBorder(),
        onPressed: () async {
          Navigator.of(context).push(
            GroupEditPage.route(),
          );
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: true,
        title: Text(l10n.groupsTitle),
      ),
      body: GroupListView(),
    );
  }
}

class GroupListView extends StatelessWidget {
  const GroupListView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        final groups = state.groups;
        return SlidableAutoCloseBehavior(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: groups.length + 1,
            itemBuilder: (BuildContext context, int index) {
              AccountGroup? group;
              if (index > 0) {
                group = groups[index - 1];
              }
              return Slidable(
                enabled: group != null,
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) async {
                        if (group == null) return;
                        Navigator.of(context).push(
                          GroupEditPage.route(group: group),
                        );
                      },
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.surface,
                      icon: Icons.edit,
                      label: l10n.edit,
                    ),
                    SlidableAction(
                      onPressed: (_) {
                        if (group != null) {
                          context.read<AccountCubit>().deleteGroup(group);
                        }
                      },
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.surface,
                      icon: Icons.delete,
                      label: l10n.delete,
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                      '${group?.name ?? l10n.defaultGroup} (${context.read<AccountCubit>().accountCount(group?.id ?? '')})'),
                  subtitle: Text(
                    group == null ? l10n.defaultGroupDescription : group.description,
                    style: TextStyle(color: colorScheme.outline),
                  ),
                  onTap: () {
                    context.read<AccountCubit>().setGroupID(group?.id ?? '');
                    Navigator.of(context).push(
                      AccountFilterPage.route(),
                    );
                  },
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(height: 0);
            },
          ),
        );
      },
    );
  }
}
