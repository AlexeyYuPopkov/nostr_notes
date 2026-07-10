import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/bloc/onboarding_screen_bloc.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_pin_page/onboarding_pin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../integration_test/di/in_memory_db_module.dart';
import '../../integration_test/di/test_app_di_overrides_proxy.dart';
import '../tools/app_launcher/app_launcher.dart';

const _keys = UserKeys(
  publicKey: 'bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe',
  privateKey:
      'efb23a073532e28f8f3cf1b3ba4bc92f1bb6ab4dd365c853cabf9b70044e3240',
);

String _pinFlagKey(String pubkey) => 'pin_enabled_flag_$pubkey';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'relay_urls': <String>['wss://test.relay'],
      _pinFlagKey(_keys.publicKey): false,
    });
    final di = DiStorage.shared;
    const InMemoryDbModule().bind(di);
    await const TestAppDiOverridesProxy().bindUnauthModules();
    di.resolve<SessionUsecase>().setSession(const Auth(_keys));
  });

  tearDown(() async => DiStorage.shared.removeAll());

  testWidgets('no-PIN account shows the auto-unlock UI, not the PIN form', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppLauncher.launchApp(tester: tester, child: const _Host()),
    );
    // Let the bloc authenticate and flip into auto-unlock mode.
    await tester.pump();
    await tester.pump();

    expect(find.text('Unlocking account'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Set a PIN or password'), findsNothing);

    // Stop the pending auto-unlock timer before the test ends.
    await tester.tap(find.text('Cancel'));
    await tester.pump();
  });

  testWidgets('Cancel halts the auto-unlock and reveals a manual Unlock', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppLauncher.launchApp(tester: tester, child: const _Host()),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Cancel'));
    await tester.pump();

    expect(find.text('Set a PIN or password'), findsOneWidget);
    expect(find.text('Unlock'), findsNothing);

    expect(
      DiStorage.shared.resolve<SessionUsecase>().currentSession.isUnlocked,
      isFalse,
    );
  });

  testWidgets('the countdown auto-unlocks the session when not cancelled', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppLauncher.launchApp(tester: tester, child: const _Host()),
    );
    await tester.pump();
    await tester.pump();

    expect(
      DiStorage.shared.resolve<SessionUsecase>().currentSession.isUnlocked,
      isFalse,
    );

    // Elapse past the auto-unlock delay, then let the bloc process onPin.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    await tester.pump();

    expect(
      DiStorage.shared.resolve<SessionUsecase>().currentSession.isUnlocked,
      isTrue,
    );
  });
}

final class _Host extends StatelessWidget {
  const _Host();

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Disable the InkSparkle ripple, whose shader asset can't load in the
      // widget-test bundle (tapping the buttons would otherwise throw).
      data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
      child: Scaffold(
        body: BlocProvider(
          create: (_) => OnboardingScreenBloc(),
          child: const OnboardingPinPage(),
        ),
      ),
    );
  }
}
