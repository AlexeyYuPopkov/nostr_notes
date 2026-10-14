import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/common/presentation/account_avatar.dart';

const _pubkey =
    'a7b73fbd00000000000000000000000000000000000000000000000000001ea13c';

Widget _host(String? pictureUrl) => MaterialApp(
  home: Center(
    child: AccountAvatar(pubkey: _pubkey, size: 40, pictureUrl: pictureUrl),
  ),
);

void main() {
  testWidgets('shows the initials when there is no picture', (tester) async {
    await tester.pumpWidget(_host(null));

    expect(find.text('A7'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('keeps the initials visible until the picture has a frame', (
    tester,
  ) async {
    await tester.pumpWidget(_host('https://example.com/avatar.png'));
    await tester.pump();

    expect(find.text('A7'), findsOneWidget);
    final image = find.byType(Image);
    expect(image, findsOneWidget);
    expect(
      find.descendant(of: image, matching: find.byType(RawImage)),
      findsNothing,
    );

    // The load never finishes in a test, so its cache entry would leak.
    await tester.pumpWidget(const SizedBox());
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  });
}
