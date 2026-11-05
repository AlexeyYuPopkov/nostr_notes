import 'package:common/domain/model/user.dart';
import 'package:equatable/equatable.dart';

final class SearchContactData extends Equatable {
  final String query;
  final List<User> users;

  const SearchContactData._({required this.query, required this.users});

  factory SearchContactData.initial() =>
      const SearchContactData._(query: '', users: []);

  bool get hasQuery => query.isNotEmpty;

  SearchContactData copyWith({String? query, List<User>? users}) {
    return SearchContactData._(
      query: query ?? this.query,
      users: users ?? this.users,
    );
  }

  @override
  List<Object?> get props => [query, users];
}
