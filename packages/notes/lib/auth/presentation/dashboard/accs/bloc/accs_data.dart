import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';

final class AccsData extends Equatable {
  /// All decrypted login items of the current account.
  final List<LoginItem> items;

  /// Subset of [items] matching [searchString]; only meaningful while
  /// [searchString] is non-empty.
  final List<LoginItem> filtered;

  final String searchString;

  const AccsData._({
    required this.items,
    required this.filtered,
    required this.searchString,
  });

  factory AccsData.initial() {
    return const AccsData._(items: [], filtered: [], searchString: '');
  }

  /// Items to display: the filtered subset while searching, otherwise all.
  List<LoginItem> get visibleItems =>
      searchString.trim().isEmpty ? items : filtered;

  bool get isSearching => searchString.trim().isNotEmpty;

  @override
  List<Object?> get props => [items, filtered, searchString];

  AccsData copyWith({
    List<LoginItem>? items,
    List<LoginItem>? filtered,
    String? searchString,
  }) {
    return AccsData._(
      items: items ?? this.items,
      filtered: filtered ?? this.filtered,
      searchString: searchString ?? this.searchString,
    );
  }
}
