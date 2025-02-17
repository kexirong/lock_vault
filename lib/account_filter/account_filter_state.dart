part of 'account_filter_bloc.dart';

final class AccountFilterState extends Equatable {
  const AccountFilterState({
    this.filter = '',
  });

  final String filter;

  @override
  List<Object> get props => [filter];

  AccountFilterState copyWith({
    String? filter,
  }) {
    return AccountFilterState(
      filter: filter ?? this.filter,
    );
  }
}
