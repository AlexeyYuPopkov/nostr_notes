import 'package:chat/unauth/presentation/onboarding/onboarding_screen.dart';
import 'package:common/data/repo/app_theme_data_repo_impl.dart';
import 'package:common/presentation/theme_settings/global_settings_vm.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../common/test/tools/moks/app_shared_prefs_mock.dart';
import 'tools/app_launcher/app_launcher.dart';

void main() {
  group('OnboardingScreen', () {
    late GlobalSettingsVm vm;

    setUp(() async {
      vm = GlobalSettingsVm(
        appThemeDataRepo: AppThemeDataRepoImpl(AppSharedPrefsMock()),
      );
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
