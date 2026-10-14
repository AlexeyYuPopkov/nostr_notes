import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';

final class AccsData extends Equatable {
  final List<LoginItem> items;
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

  List<AccsDataItem> get displayItems => [
    for (final item in visibleItems) AccsDataLoginItem(item: item),
  ];

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

/// A row of the accounts list.
sealed class AccsDataItem extends Equatable {
  const AccsDataItem();
}

final class AccsDataLoginItem extends AccsDataItem {
  final LoginItem item;
  const AccsDataLoginItem({required this.item});

  @override
  List<Object?> get props => [item];
}
