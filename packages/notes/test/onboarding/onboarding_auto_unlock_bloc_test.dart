import 'package:di_storage/di_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/bloc/onboarding_screen_bloc.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/bloc/onboarding_screen_state.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_step.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../integration_test/di/in_memory_db_module.dart';
import '../../integration_test/di/test_app_di_overrides_proxy.dart';

const _keys = UserKeys(
  publicKey:
      'bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe',
  privateKey:
      'efb23a073532e28f8f3cf1b3ba4bc92f1bb6ab4dd365c853cabf9b70044e3240',
);

String _pinFlagKey(String pubkey) => 'pin_enabled_flag_$pubkey';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> bindWith(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues({
      'relay_urls': <String>['wss://test.relay'],
      ...prefs,
    });
    final di = DiStorage.shared;
    const InMemoryDbModule().bind(di);
    await const TestAppDiOverridesProxy().bindUnauthModules();
  }

  tearDown(() async {
    // The DB is never used here; resolving it would construct the real native
    // drift DB. removeAll just drops the bindings.
    DiStorage.shared.removeAll();
  });

  Matcher pinStepWith({required bool autoUnlock}) => emitsThrough(
    predicate<OnboardingScreenState>(
      (s) => s.data.step is OnboardingPin && s.data.autoUnlock == autoUnlock,
      'PIN step with autoUnlock=$autoUnlock',
    ),
  );

  test('auto-unlocks for an account that explicitly opted out of PIN', () async {
    await bindWith({_pinFlagKey(_keys.publicKey): false});
    DiStorage.shared.resolve<SessionUsecase>().setSession(const Auth(_keys));

    final bloc = OnboardingScreenBloc();
    addTearDown(bloc.close);

    await expectLater(bloc.stream, pinStepWith(autoUnlock: true));
  });

  test('requires PIN for a PIN-enabled account', () async {
    await bindWith({_pinFlagKey(_keys.publicKey): true});
    DiStorage.shared.resolve<SessionUsecase>().setSession(const Auth(_keys));

    final bloc = OnboardingScreenBloc();
    addTearDown(bloc.close);

    await expectLater(bloc.stream, pinStepWith(autoUnlock: false));
  });

  test('requires PIN for a fresh account with no stored flag', () async {
    // No pin_enabled_flag entry → getForUser defaults to true (PIN required),
    // so a brand-new account never auto-unlocks.
    await bindWith({});
    DiStorage.shared.resolve<SessionUsecase>().setSession(const Auth(_keys));

    final bloc = OnboardingScreenBloc();
    addTearDown(bloc.close);

    await expectLater(bloc.stream, pinStepWith(autoUnlock: false));
  });
}
