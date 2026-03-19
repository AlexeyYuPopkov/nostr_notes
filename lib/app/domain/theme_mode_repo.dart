abstract interface class ThemeModeRepo {
  const ThemeModeRepo();
  AppThemeMode get();
  Future<void> set(AppThemeMode themeMode);
}

enum AppThemeMode {
  system,
  light,
  dark;

  static const systemStr = 'system';
  static const lightStr = 'light';
  static const darkStr = 'dark';

  @override
  String toString() {
    switch (this) {
      case AppThemeMode.system:
        return systemStr;
      case AppThemeMode.light:
        return lightStr;
      case AppThemeMode.dark:
        return darkStr;
    }
  }

  factory AppThemeMode.fromString(String value) {
    switch (value) {
      case systemStr:
        return AppThemeMode.system;
      case lightStr:
        return AppThemeMode.light;
      case darkStr:
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }
}
