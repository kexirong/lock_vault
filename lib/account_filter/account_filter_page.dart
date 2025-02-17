import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lock_vault/l10n/l10n.dart';

import '../account/account_cubit.dart';
import '../account/account_list_widget.dart';
import 'account_filter_bloc.dart';

class AccountFilterPage extends StatelessWidget {
  const AccountFilterPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => AccountFilterBloc(),
        child: const AccountFilterPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const AccountFilterView();
  }
}

class AccountFilterView extends StatelessWidget {
  const AccountFilterView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
final l10n=context.l10n;
    return BlocBuilder<AccountFilterBloc, AccountFilterState>(
      builder: (context, state) {
        final filter = state.filter;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            centerTitle: true,
            title: Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              height: 40,
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.search,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  filled: true,
                  fillColor: colorScheme.onPrimary,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onChanged: (value) {
                  context.read<AccountFilterBloc>().add(AccountFilterChanged(value));
                },
              ),
            ),
          ),
          body: BlocBuilder<AccountCubit, AccountState>(
            builder: (context, state) {
              var accounts = state.accountsWithGroup;
              if (filter.isNotEmpty) {
                accounts = accounts.where((account) => account.title.contains(filter.trim()));
              }
              return AccountListWidget([...accounts]);
            },
          ),
        );
      },
    );
  }
}
