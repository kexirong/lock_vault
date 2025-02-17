part of 'account_cubit.dart';

enum AccountStatus { initial, loading, success, failure }

final class AccountState extends Equatable {
  const AccountState({
    this.status = AccountStatus.initial,
    this.accounts = const [],
    this.groups = const [],
    this.groupID,
  });

  final AccountStatus status;
  final List<BaseAccount> accounts;
  final List<AccountGroup> groups;
  final String? groupID;

  Iterable<BaseAccount> get accountsWithGroup {
    if (groupID == null) return accounts;
    return accounts.where((item) => item.groupID == groupID);
  }

  AccountState copyWith({
    AccountStatus? status,
    List<BaseAccount>? accounts,
    List<AccountGroup>? groups,
    String? groupID,
  }) {
    return AccountState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      groups: groups ?? this.groups,
      groupID: groupID == null ? this.groupID : (groupID == 'null' ? null : groupID),
    );
  }

  @override
  List<Object?> get props => [status, accounts, groups, groupID];
}
