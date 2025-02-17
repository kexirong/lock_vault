import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/account.dart';

part 'account_edit_state.dart';

class AccountEditCubit extends Cubit<AccountEditState> {
  AccountEditCubit({
    required PlainAccount? account,
  }) : super(AccountEditState(account: account));

  void addExtendField() {
    final account = state.account.copyWith(extendField: {...state.account.extendField, '': ''});
    emit(state.copyWith(account: account));
  }

  void onEdit(PlainAccount? account) {
    emit(state.copyWith(account: account));
  }

  void onSubmit() {
    emit(state.copyWith(status: AccountEditStatus.loading));
  }

  void onSuccess() {
    emit(state.copyWith(status: AccountEditStatus.success));
  }
}
