import 'package:flutter/widgets.dart';

import '../../presentation/theme_settings/global_settings_vm.dart';

class GlobalSettingsScope extends InheritedWidget {
  const GlobalSettingsScope({
    required this.vm,
    required super.child,
    super.key,
  });

  final GlobalSettingsVm vm;

  static GlobalSettingsVm of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<GlobalSettingsScope>();
    assert(scope != null, 'GlobalSettingsScope not found in widget tree');
    return scope!.vm;
  }

  static GlobalSettingsVm? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<GlobalSettingsScope>()
        ?.vm;
  }

  @override
  bool updateShouldNotify(GlobalSettingsScope old) => vm != old.vm;
}
