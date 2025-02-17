import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../l10n/l10n.dart';
import '../setting/setting_cubit.dart';
import '../account_edit/account_edit_page.dart';
import '../models/account.dart';
import 'account_cubit.dart';
import 'account_detail_widget.dart';

class AccountListWidget extends StatelessWidget {
  final List<BaseAccount> accounts;

  const AccountListWidget(this.accounts, {super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return SlidableAutoCloseBehavior(
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: accounts.length,
        itemBuilder: (BuildContext context, int index) {
          var account = accounts[index];
          if (account is EncryptAccount) {
            var secret = context.read<SettingCubit>().state.getSecret(account.mKey);
            if (secret != null) {
              account = account.decrypt(secret);
            }
          }
          return Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    if (account is EncryptAccount) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(l10n.unableDecrypted),
                      ));
                    }
                    Navigator.of(context).push(
                      AccountEditPage.route(account: account as PlainAccount),
                    );
                  },
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.surface,
                  icon: Icons.edit,
                  label: l10n.edit,
                ),
                SlidableAction(
                  onPressed: (context) {
                    if (account is EncryptAccount) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(l10n.unableDecrypted),
                      ));
                    }
                    context.read<AccountCubit>().deleteAccount(account);
                  },
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.surface,
                  icon: Icons.delete,
                  label: l10n.delete,
                ),
              ],
            ),
            child: ListTile(
              title: Text(account.title),
              subtitle: Text(
                overflow: TextOverflow.ellipsis,
                'URL: ${account is PlainAccount ? account.url : l10n.unableDecrypted}',
                style: TextStyle(color: colorScheme.outline),
              ),
              onTap: () {
                if (account is EncryptAccount) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(l10n.unableDecrypted),
                  ));
                  return;
                }
                showDialog<String>(
                    context: context,
                    builder: (BuildContext context) {
                      return AccountDetailWidget(account: account as PlainAccount);
                    });
              },
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(height: 0);
        },
      ),
    );
  }
}
