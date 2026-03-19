import 'dart:async';

import 'package:nostr_notes/auth/domain/repo/is_first_launch_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class IsFirstLaunchRepoImpl implements IsFirstLaunchRepo {
  final SharedPreferences _prefs;
  static const _key = 'is_first_launch_flag';

  const IsFirstLaunchRepoImpl(this._prefs);

  @override
  bool get() {
    final result = _prefs.getBool(_key) ?? true;
    unawaited(_prefs.setBool(_key, false));
    return result;
  }
}
