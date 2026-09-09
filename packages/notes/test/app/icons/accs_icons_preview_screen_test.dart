import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/app/icons/accs_icons.dart';
import 'package:nostr_notes/app/icons/accs_icons_preview_screen.dart';

import '../../tools/app_launcher/app_launcher.dart';

void main() {
  test('AccsIcons.bySlug has one distinct, non-zero codepoint per slug', () {
    final codePoints = AccsIcons.bySlug.values
        .map((icon) => icon.codePoint)
        .toSet();

    expect(codePoints.length, AccsIcons.bySlug.length);
    expect(codePoints.every((cp) => cp > 0), isTrue);
  });

  testWidgets(
    'AccsIconsPreviewScreen renders every glyph in AccsIcons.bySlug',
    (tester) async {
      await tester.pumpWidget(
        AppLauncher.launchApp(
          tester: tester,
          child: const AccsIconsPreviewScreen(),
        ),
      );
      await tester.pump();

      // GridView.builder only builds visible tiles, so scroll to the end,
      // collecting every codepoint that actually made it through a real
      // paint pass — a bad `family:` registration or a stale/garbled
      // codepoint map would throw or leave gaps here.
      final seen = <int>{};
      var previousSeen = -1;
      var attempts = 0;
      while (seen.length < AccsIcons.bySlug.length && attempts < 60) {
        for (final icon in tester.widgetList<Icon>(find.byType(Icon))) {
          final codePoint = icon.icon?.codePoint;
          if (codePoint != null) {
            seen.add(codePoint);
          }
        }
        if (seen.length == previousSeen) {
          break; // reached the bottom of the grid
        }
        previousSeen = seen.length;

        await tester.drag(find.byType(GridView), const Offset(0, -400));
        await tester.pump();
        attempts++;
      }

      expect(seen.length, AccsIcons.bySlug.length);
    },
  );
}
