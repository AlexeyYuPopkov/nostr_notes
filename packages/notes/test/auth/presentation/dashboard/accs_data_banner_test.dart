import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/presentation/dashboard/accs/bloc/accs_data.dart';

LoginItem _item(String title) => LoginItem(
  eventId: title,
  dTag: title,
  title: title,
  username: '$title@example.com',
  password: 'p',
  websiteUrl: '',
  notes: '',
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

AccsData _dataWith(int count, {String search = ''}) {
  final items = [for (var i = 0; i < count; i++) _item('item$i')];
  return AccsData.initial().copyWith(
    items: items,
    filtered: items,
    searchString: search,
  );
}

int _bannerIndex(List<AccsDataItem> rows) =>
    rows.indexWhere((r) => r is AccsDataAdBanner);

void main() {
  group('AccsData.displayItems', () {
    test('puts the banner below the first few credentials, not above them', () {
      final rows = _dataWith(10).displayItems;

      expect(_bannerIndex(rows), AccsData.adBannerOffset);
      expect(rows.first, isA<AccsDataLoginItem>());
      expect(rows.length, 11);
    });

    test('appends the banner when there are fewer items than the offset', () {
      final rows = _dataWith(2).displayItems;

      expect(_bannerIndex(rows), 2);
      expect(rows.last, isA<AccsDataAdBanner>());
    });

    test('no rows at all means no banner', () {
      expect(_dataWith(0).displayItems, isEmpty);
    });

    test('search results stay free of the banner', () {
      final rows = _dataWith(10, search: 'item').displayItems;

      expect(_bannerIndex(rows), -1);
      expect(rows, everyElement(isA<AccsDataLoginItem>()));
    });

    test('exactly one banner is emitted', () {
      final rows = _dataWith(50).displayItems;

      expect(rows.whereType<AccsDataAdBanner>().length, 1);
    });
  });
}
