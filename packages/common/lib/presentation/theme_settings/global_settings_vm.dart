import 'package:common/domain/error/app_error.dart';
import 'package:common/domain/repo/app_theme_data_repo_impl.dart';
import 'package:flutter/material.dart';

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
  late final ValueNotifier<int> lightBgIndexNotifier;
  late final ValueNotifier<int> darkBgIndexNotifier;
  late final ValueNotifier<int> lightCardIndexNotifier;
  late final ValueNotifier<int> darkCardIndexNotifier;
  late final ValueNotifier<AppError?> errorNotifier;

  GlobalSettingsVm({required AppThemeDataRepo appThemeDataRepo})
    : _appThemeDataRepo = appThemeDataRepo {
    final appThemeData = _appThemeDataRepo.load();
    themeModeNotifier = ValueNotifier(appThemeData.themeMode);
    lightBgIndexNotifier = ValueNotifier(appThemeData.lightBgIndex);
    darkBgIndexNotifier = ValueNotifier(appThemeData.darkBgIndex);
    lightCardIndexNotifier = ValueNotifier(appThemeData.lightCardIndex);
    darkCardIndexNotifier = ValueNotifier(appThemeData.darkCardIndex);
    errorNotifier = ValueNotifier(null);
  }

  ThemeMode get themeMode => themeModeNotifier.value;

  Future<void> setThemeMode(ThemeMode value) async {
    final result = await _setAppThemeData(
      _appThemeDataRepo.load().copyWith(themeMode: value),
    );
    if (result != null) {
      themeModeNotifier.value = value;
    }
  }

  Future<void> setLightBgIndex(int value) async {
    final result = await _setAppThemeData(
      _appThemeDataRepo.load().copyWith(lightBgIndex: value),
    );
    if (result != null) {
      lightBgIndexNotifier.value = value;
    }
  }

  Future<void> setDarkBgIndex(int value) async {
    final result = await _setAppThemeData(
      _appThemeDataRepo.load().copyWith(darkBgIndex: value),
    );
    if (result != null) {
      darkBgIndexNotifier.value = value;
    }
  }

  Future<void> setLightCardIndex(int value) async {
    final result = await _setAppThemeData(
      _appThemeDataRepo.load().copyWith(lightCardIndex: value),
    );
    if (result != null) {
      lightCardIndexNotifier.value = value;
    }
  }

  Future<void> setDarkCardIndex(int value) async {
    final result = await _setAppThemeData(
      _appThemeDataRepo.load().copyWith(darkCardIndex: value),
    );
    if (result != null) {
      darkCardIndexNotifier.value = value;
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

  int get lightBgIndex => lightBgIndexNotifier.value;
  int get darkBgIndex => darkBgIndexNotifier.value;
  int get lightCardIndex => lightCardIndexNotifier.value;
  int get darkCardIndex => darkCardIndexNotifier.value;
}
