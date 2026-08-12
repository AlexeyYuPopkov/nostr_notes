import 'package:common/app/theme/app_theme_style.dart';
import 'package:common/domain/error/app_error.dart';
import 'package:common/domain/repo/app_theme_data_repo_impl.dart';
import 'package:flutter/material.dart';
import 'package:common/presentation/tools/optional_box.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class GlobalSettingsError extends AppError {
  const GlobalSettingsError({super.parentError, super.reason});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GlobalSettingsError &&
        other.reason == reason &&
        other.parentError == parentError;
  }

  @override
  int get hashCode => Object.hash(reason, parentError);
}

final class GlobalSettingsVm {
  final AppThemeDataRepo _appThemeDataRepo;
  late final ValueNotifier<ThemeMode> themeModeNotifier;
  late final ValueNotifier<Locale?> localeNotifier;
  late final ValueNotifier<AppThemeStyle> lightThemeStyleNotifier;
  late final ValueNotifier<AppThemeStyle> darkThemeStyleNotifier;
  late final ValueNotifier<AppError?> errorNotifier;

  GlobalSettingsVm({required AppThemeDataRepo appThemeDataRepo})
    : _appThemeDataRepo = appThemeDataRepo {
    final appThemeData = _appThemeDataRepo.load();
    themeModeNotifier = ValueNotifier(appThemeData.themeMode);
    localeNotifier = ValueNotifier(_parseLocale(appThemeData.localeCode.value));
    lightThemeStyleNotifier = ValueNotifier(appThemeData.lightThemeStyle);
    darkThemeStyleNotifier = ValueNotifier(appThemeData.darkThemeStyle);
    errorNotifier = ValueNotifier(null);
  }

  ThemeMode get themeMode => themeModeNotifier.value;
  Locale? get locale => localeNotifier.value;

  Future<void> setThemeMode(ThemeMode value) async {
    final result = await _setAppThemeData(
      _appThemeDataRepo.load().copyWith(themeMode: value),
    );
    if (result != null) {
      themeModeNotifier.value = value;
    }
  }

  Future<void> setLightThemeStyle(AppThemeStyle value) async {
    final result = await _setAppThemeData(
      _appThemeDataRepo.load().copyWith(lightThemeStyle: value),
    );
    if (result != null) {
      lightThemeStyleNotifier.value = value;
    }
  }

  Future<void> setDarkThemeStyle(AppThemeStyle value) async {
    final result = await _setAppThemeData(
      _appThemeDataRepo.load().copyWith(darkThemeStyle: value),
    );
    if (result != null) {
      darkThemeStyleNotifier.value = value;
    }
  }

  Future<void> setLocale(Locale? value) async {
    final localeCode = value?.languageCode;
    final result = await _setAppThemeData(
      _appThemeDataRepo.load().copyWith(localeCode: OptionalBox(localeCode)),
    );
    if (result != null) {
      localeNotifier.value = _parseLocale(result.localeCode.value);
    }
  }

  Future<AppThemeData?> _setAppThemeData(AppThemeData data) async {
    try {
      await _appThemeDataRepo.save(data);
      return _appThemeDataRepo.load();
    } catch (e) {
      errorNotifier.value = AppError.custom<GlobalSettingsError>(
        payload: GlobalSettingsError(
          parentError: e,
          reason: 'Failed to save app theme data',
        ),
        parentError: e,
      );
      return null;
    }
  }

  AppThemeStyle get lightThemeStyle => lightThemeStyleNotifier.value;
  AppThemeStyle get darkThemeStyle => darkThemeStyleNotifier.value;

  Locale? _parseLocale(String? value) {
    if (value == null || value.isEmpty) return null;

    final parts = value.split(RegExp(r'[-_]'));
    return Locale(parts.first, parts.elementAtOrNull(1));
  }
}

enum LanguageCode {
  system,
  en,
  ru,
  bg;

  String getLocalizedName(Localization l10n) {
    return switch (this) {
      LanguageCode.system => l10n.preferencesScreenLanguageSystem,
      LanguageCode.ru => l10n.preferencesScreenLanguageRussian,
      LanguageCode.en => l10n.preferencesScreenLanguageEnglish,
      LanguageCode.bg => l10n.preferencesScreenLanguageBulgarian,
    };
  }

  Locale? get locale => switch (this) {
    LanguageCode.system => null,
    LanguageCode.en => const Locale('en'),
    LanguageCode.ru => const Locale('ru'),
    LanguageCode.bg => const Locale('bg'),
  };
}

extension GetLanguageCode on Locale? {
  LanguageCode get code {
    return switch (this?.languageCode) {
      'en' => LanguageCode.en,
      'ru' => LanguageCode.ru,
      'bg' => LanguageCode.bg,
      _ => LanguageCode.system,
    };
  }
}
