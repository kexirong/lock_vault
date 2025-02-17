part of 'group_edit_cubit.dart';

enum GroupEditStatus { initial, loading, success, failure }

final class GroupEditState extends Equatable {
  GroupEditState({
    this.status = GroupEditStatus.initial,
    AccountGroup? group,
    bool? isEdit,
  })  : group = group ?? AccountGroup(),
        isEdit = isEdit ?? group != null;

  final GroupEditStatus status;
  final bool isEdit;
  final AccountGroup group;

  GroupEditState copyWith({
    GroupEditStatus? status,
    AccountGroup? group,
  }) {
    return GroupEditState(
      status: status ?? this.status,
      group: group ?? this.group,
      isEdit: isEdit,
    );
  }

  @override
  List<Object?> get props => [status, group];
}
