import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';

final class AccsData extends Equatable {
  static const adBannerOffset = 3;

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

  List<AccsDataItem> get displayItems {
    final rows = [
      for (final item in visibleItems) AccsDataLoginItem(item: item),
    ];
    if (isSearching || rows.isEmpty) return rows;

    final at = rows.length < adBannerOffset ? rows.length : adBannerOffset;
    return [...rows.take(at), const AccsDataAdBanner(), ...rows.skip(at)];
  }

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

/// A row of the accounts list: either a stored credential or the ad slot.
sealed class AccsDataItem extends Equatable {
  const AccsDataItem();
}

final class AccsDataLoginItem extends AccsDataItem {
  final LoginItem item;
  const AccsDataLoginItem({required this.item});

  @override
  List<Object?> get props => [item];
}

final class AccsDataAdBanner extends AccsDataItem {
  const AccsDataAdBanner();

  @override
  List<Object?> get props => const [];
}
