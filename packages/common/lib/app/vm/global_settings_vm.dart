import 'package:flutter/material.dart';

final class GlobalSettingsVm {
  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
    ThemeMode.system,
  );

  GlobalSettingsVm();

  ThemeMode get themeMode => themeModeNotifier.value;

  set themeMode(ThemeMode value) {
    themeModeNotifier.value = value;
  }
}
