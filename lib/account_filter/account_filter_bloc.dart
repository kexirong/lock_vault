import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'account_filter_state.dart';

class AccountFilterBloc extends Bloc<AccountFilterEvent, AccountFilterState> {
  AccountFilterBloc() : super(const AccountFilterState()) {
    on<AccountFilterChanged>(_onFilterChanged);
  }

  void _onFilterChanged(
    AccountFilterChanged event,
    Emitter<AccountFilterState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }
}

sealed class AccountFilterEvent extends Equatable {
  const AccountFilterEvent();
}

final class AccountFilterChanged extends AccountFilterEvent {
  const AccountFilterChanged(this.filter);

  final String filter;

  @override
  List<Object> get props => [filter];
}
