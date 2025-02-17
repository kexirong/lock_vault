import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/account.dart';
import '../models/account_group.dart';
import '../repository/account_repository.dart';

part 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit({
    required AccountRepository accountRepository,
  })  : _accountRepository = accountRepository,
        super(const AccountState()) {
    _init();
  }

  final AccountRepository _accountRepository;

  void _init() {
    () async {
      final accounts = await _accountRepository.getAccounts();
      final groups = await _accountRepository.getGroups();
      emit(state.copyWith(
        status: AccountStatus.success,
        accounts: accounts,
        groups: groups,
      ));
    }();
  }

  void setGroupID(String? groupID) {
    emit(state.copyWith(
      groupID: groupID,
    ));
  }

  Future<void> addAccount(BaseAccount account) async {
    emit(state.copyWith(status: AccountStatus.loading));

    await _accountRepository.addAccount(account);

    state.accounts.add(account);
    emit(state.copyWith(
      status: AccountStatus.success,
    ));
  }

  Future<void> updateAccount(BaseAccount account) async {
    emit(state.copyWith(status: AccountStatus.loading));

    int index = state.accounts.indexWhere((el) => (el.id == account.id));
    if (index < 0) {
      return emit(state.copyWith(
        status: AccountStatus.failure,
      ));
    }
    await _accountRepository.updateAccount(account);
    state.accounts[index] = account;
    emit(state.copyWith(
      status: AccountStatus.success,
    ));
  }

  void deleteAccount(BaseAccount account) {
    emit(state.copyWith(status: AccountStatus.loading));

    int index = state.accounts.indexWhere((el) => (el.id == account.id));
    if (index < 0) {
      return emit(state.copyWith(
        status: AccountStatus.failure,
      ));
    }

    _accountRepository.deleteAccount(account).then((value) {
      state.accounts.removeAt(index);
      emit(state.copyWith(
        status: AccountStatus.success,
      ));
    });
  }

  int accountCount(String groupID) {
    return state.accounts.where((item) => item.groupID == groupID).length;
  }

  void addGroup(AccountGroup group) {
    emit(state.copyWith(status: AccountStatus.loading));

    _accountRepository.addGroup(group).then((value) {
      state.groups.add(group);
      emit(state.copyWith(
        status: AccountStatus.success,
      ));
    });
  }

  void updateGroup(AccountGroup group) {
    emit(state.copyWith(status: AccountStatus.loading));

    int index = state.groups.indexWhere((el) => (el.id == group.id));
    if (index < 0) {
      return emit(state.copyWith(
        status: AccountStatus.failure,
      ));
    }
    _accountRepository.updateGroup(group).then((value) {
      state.groups[index] = group;
      emit(state.copyWith(
        status: AccountStatus.success,
      ));
    });
  }

  void deleteGroup(AccountGroup group) {
    emit(state.copyWith(status: AccountStatus.loading));

    int index = state.groups.indexWhere((el) => (el.id == group.id));
    if (index < 0) {
      return emit(state.copyWith(
        status: AccountStatus.failure,
      ));
    }
    _accountRepository.deleteGroup(group).then((value) {
      state.groups.removeAt(index);
      emit(state.copyWith(
        status: AccountStatus.success,
      ));
    });
  }
}
