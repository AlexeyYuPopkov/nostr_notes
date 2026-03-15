import 'package:nostr_notes/auth/domain/repo/desktop_ratio_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class DesktopRatioRepoImpl implements DesktopRatioRepo {
  final SharedPreferences _prefs;
  static const _key = ' desktop_ratio_flag';

  DesktopRatioRepoImpl(this._prefs);

  @override
  double? getForUser(String pubkey) {
    return _prefs.getDouble(_createKey(pubkey));
  }

  @override
  Future<void> setForUser(double ratio, {required String pubkey}) async {
    await _prefs.setDouble(_createKey(pubkey), ratio);
  }

  String _createKey(String pubkey) => [_key, pubkey].join('_');
}
