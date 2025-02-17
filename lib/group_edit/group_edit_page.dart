import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../account/account_cubit.dart';
import '../models/account_group.dart';
import '../l10n/l10n.dart';
import 'group_edit_cubit.dart';

class GroupEditPage extends StatelessWidget {
  const GroupEditPage({super.key});

  static Route<void> route({AccountGroup? group}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => GroupEditCubit(group: group),
        child: const GroupEditPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AccountCubit, AccountState>(
          listenWhen: (previous, current) =>
              previous.status == AccountStatus.loading && current.status == AccountStatus.success,
          listener: (context, state) => context.read<GroupEditCubit>().onSuccess(),
        ),
        BlocListener<GroupEditCubit, GroupEditState>(
          listenWhen: (previous, current) =>
              previous.status != current.status && current.status == GroupEditStatus.success,
          listener: (context, state) => Navigator.of(context).pop(),
        )
      ],
      child: const GroupEditView(),
    );
  }
}

class GroupEditView extends StatelessWidget {
  const GroupEditView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GroupEditCubit>();
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
          title: Text(
        cubit.state.isEdit ? l10n.editAccountGroupTitle : l10n.addAccountGroupTitle,
      )),
      floatingActionButton: BlocSelector<GroupEditCubit, GroupEditState, GroupEditStatus>(
        selector: (state) => state.status,
        builder: (context, status) {
          return FloatingActionButton(
            shape: const ContinuousRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32)),
            ),
            onPressed: () {
              if (status == GroupEditStatus.loading) return;
              cubit.onSubmit();
              if (cubit.state.isEdit) {
                context.read<AccountCubit>().updateGroup(cubit.state.group);
              } else {
                context.read<AccountCubit>().addGroup(cubit.state.group);
              }
            },
            child: status == GroupEditStatus.loading
                ? const CircularProgressIndicator.adaptive()
                : const Icon(Icons.check_rounded),
          );
        },
      ),
      body: const Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _NameField(),
                _DescriptionField(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _notEmptyValidator(value) {
  if (value == null || value.isEmpty) {
    return 'please fill in this field';
  }
  return null;
}

class _NameField extends StatelessWidget {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GroupEditCubit>();
    final l10n = context.l10n;
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Text(l10n.groupName, style: TextStyle(fontSize: 20), textAlign: TextAlign.end),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 4, left: 2),
          child: Text(':', style: TextStyle(fontSize: 20)),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            initialValue: cubit.state.group.name,
            decoration: const InputDecoration(
              // enabled: !state.status.isLoadingOrSuccess,
              border: UnderlineInputBorder(),
            ),
            onChanged: (value) {
              cubit.onEdit(cubit.state.group.copyWith(name: value));
            },
            validator: _notEmptyValidator,
          ),
        ),
      ],
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GroupEditCubit>();
    final l10n = context.l10n;
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child:
              Text(l10n.groupDescription, style: TextStyle(fontSize: 20), textAlign: TextAlign.end),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 4, left: 2),
          child: Text(':', style: TextStyle(fontSize: 20)),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            initialValue: cubit.state.group.description,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
            ),
            onChanged: (value) {
              cubit.onEdit(cubit.state.group.copyWith(description: value));
            },
            validator: _notEmptyValidator,
          ),
        ),
      ],
    );
  }
}
