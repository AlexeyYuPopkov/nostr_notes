final class LayoutConfig {
  /// [desktopScreenWidth = 600]
  static const desktopScreenWidth = 600.0;

  /// Body ratio range for resizable split view
  static const minBodyRatio = 0.25;
  static const maxBodyRatio = 0.5;
  static const defaultBodyRatio = 0.35;

  static double getRatio(double? preferredRatio) {
    final ratio = preferredRatio;
    if (ratio == null) {
      return defaultBodyRatio;
    }

    if (ratio >= minBodyRatio && ratio <= maxBodyRatio) {
      return ratio;
    }

    return defaultBodyRatio;
  }

  /// [drawerRatio = 0.7]
  static const drawerRatio = 0.7;

  /// [switcherDrawerRatio = 0.4] - width ratio for the account switcher drawer
  static const switcherDrawerRatio = 0.4;

  /// [internalAnimations = false]
  static const internalAnimations = true;
}
