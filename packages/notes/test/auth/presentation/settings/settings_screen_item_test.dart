import 'package:common/presentation/tools/list_item_position.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/items/settings_screen_item.dart';

void main() {
  group('SettingsItem.sections', () {
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('mobile trades the donation items for review and bug report', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final items = SettingsItem.sections.expand((e) => e);

      expect(
        items.whereType<SettingsItemDonateLightning>(),
        isEmpty,
        reason: 'ads already pay for the native mobile builds',
      );
      expect(items.whereType<SettingsItemBuyMeACoffee>(), isEmpty);
      expect(items.whereType<SettingsItemLeaveReview>(), hasLength(1));
      expect(items.whereType<SettingsItemReportBug>(), hasLength(1));
    });

    test('web and desktop keep the donation items, with no store review', () {
      // Only the desktop half is exercised here: kIsWeb is a compile-time
      // constant, so a VM test cannot enter the web branch. Both land in the
      // same `!isMobile` path — see AppPlatform.isMobile.
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      final items = SettingsItem.sections.expand((e) => e);

      expect(items.whereType<SettingsItemDonateLightning>(), hasLength(1));
      expect(items.whereType<SettingsItemBuyMeACoffee>(), hasLength(1));
      expect(
        items.whereType<SettingsItemLeaveReview>(),
        isEmpty,
        reason: 'there is no store to review the desktop build in',
      );
      expect(
        items.whereType<SettingsItemReportBug>(),
        hasLength(1),
        reason: 'GitHub issues work everywhere',
      );
    });

    test('every block closes its corners on both platforms', () {
      for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
        debugDefaultTargetPlatformOverride = platform;

        for (final section in SettingsItem.sections) {
          final positions = [
            for (final (index, _) in section.indexed)
              ListItemPosition.fromIndex(index, length: section.length),
          ];

          expect(
            positions.where((p) => p == ListItemPosition.middle).length,
            section.length <= 1 ? 0 : section.length - 2,
            reason:
                'on $platform a block of ${section.length} must start and end '
                'with a rounded item, or the list draws an open-ended box',
          );
        }
      }
    });
  });
}
