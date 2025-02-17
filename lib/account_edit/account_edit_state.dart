part of 'account_edit_cubit.dart';

enum AccountEditStatus { initial, loading, success, failure }

final class AccountEditState extends Equatable {
  AccountEditState({
    this.status = AccountEditStatus.initial,
    PlainAccount? account,
    bool? isEdit,
  })  : account = account ?? PlainAccount(),
        isEdit = isEdit ?? account != null;

  final AccountEditStatus status;
  final bool isEdit;
  final PlainAccount account;

  AccountEditState copyWith({
    AccountEditStatus? status,
    PlainAccount? account,
  }) {
    return AccountEditState(
      status: status ?? this.status,
      account: account ?? this.account,
      isEdit: isEdit,
    );
  }

  @override
  List<Object?> get props => [
        status,
        account,
      ];
}
