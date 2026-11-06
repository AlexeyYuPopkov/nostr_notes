import 'package:equatable/equatable.dart';

import 'search_contact_data.dart';

sealed class SearchContactState extends Equatable {
  final SearchContactData data;
  const SearchContactState({required this.data});

  @override
  List<Object?> get props => [data];
}

final class SearchContactCommon extends SearchContactState {
  const SearchContactCommon({required super.data});
}

final class SearchContactLoading extends SearchContactState {
  const SearchContactLoading({required super.data});
}

final class SearchContactError extends SearchContactState {
  final Object error;
  const SearchContactError({required super.data, required this.error});

  @override
  List<Object?> get props => [data, error];
}
