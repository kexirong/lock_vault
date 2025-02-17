import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/account_group.dart';

part 'group_edit_state.dart';

class GroupEditCubit extends Cubit<GroupEditState> {
  GroupEditCubit({
    required AccountGroup? group,
  }) : super(GroupEditState(group: group));

  void onEdit(AccountGroup? group) {
    emit(state.copyWith(group: group));
  }

  void onSubmit() {
    emit(state.copyWith(status: GroupEditStatus.loading));
  }

  void onSuccess() {
    emit(state.copyWith(status: GroupEditStatus.success));
  }
}
