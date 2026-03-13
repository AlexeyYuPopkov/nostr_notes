import 'package:nostr_notes/auth/domain/repo/pin_enabled_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class PinEnabledRepoImpl implements PinEnabledRepo {
  final SharedPreferences _prefs;
  static const _key = 'pin_enabled_flag';

  PinEnabledRepoImpl(this._prefs);

  @override
  bool getForUser(String pubkey) {
    return _prefs.getBool(_createKey(pubkey)) ?? true;
  }

  @override
  Future<void> setForUser(bool isEnabled, {required String pubkey}) async {
    await _prefs.setBool(_createKey(pubkey), isEnabled);
  }

  String _createKey(String pubkey) => [_key, pubkey].join('_');
}
