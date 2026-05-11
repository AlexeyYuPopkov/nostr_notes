import 'package:chat/unauth/presentation/onboarding/onboarding_screen.dart';
import 'package:common/app/vm/global_settings_vm.dart';
import 'package:flutter_test/flutter_test.dart';

import 'tools/app_launcher/app_launcher.dart';

void main() {
  group('OnboardingScreen', () {
    late GlobalSettingsVm vm;

    setUp(() async {
      vm = GlobalSettingsVm();
      await AppLauncher.setUp();
      addTearDown(AppLauncher.tearDown);
    });

    testWidgets('check flow', (tester) async {
      await tester.pumpWidget(
        AppLauncher.launchApp(
          child: const OnboardingScreen(),
          tester: tester,
          globalSettingsVm: vm,
        ),
      );
      await tester.pumpAndSettle();

      final screen = find.byType(OnboardingScreen);

      expect(screen, findsOneWidget);
    });
  });
}
