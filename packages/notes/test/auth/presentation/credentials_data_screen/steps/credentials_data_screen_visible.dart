import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/presentation/settings/preferences/credentials_data_screen/credentials_data_screen.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';

import '../../../data/fixtures/notes_fixtures.dart';
import '../../../../tools/app_launcher/app_launcher.dart';

/// Usage: Credentials data screen visible
///
/// The screen reads keys and PIN from the session, so it needs an unlocked
/// one; run after `a fresh install`, which binds [SessionUsecase].
Future<void> credentialsDataScreenVisible(WidgetTester tester) async {
  final SessionUsecase sessionUsecase = DiStorage.shared.resolve();
  await sessionUsecase.setSession(
    const Session.unlocked(keys: NotesFixtures.keys, pin: NotesFixtures.pin),
  );

  await tester.pumpWidget(
    AppLauncher.launchApp(
      tester: tester,
      child: Builder(
        builder: (context) => Theme(
          // The InkSparkle shader asset is missing from the widget-test bundle,
          // so a tap on a button with the default splash throws.
          data: Theme.of(
            context,
          ).copyWith(splashFactory: NoSplash.splashFactory),
          child: const CredentialsDataScreen(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.byType(CredentialsDataScreen), findsOneWidget);
}
