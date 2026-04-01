import 'package:nostr_notes/auth/domain/repo/pin_keyboard_type_repo.dart';
import 'package:nostr_notes/common/domain/model/pin_keyboard_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class PinKeyboardTypeRepoImpl implements PinKeyboardTypeRepo {
  final SharedPreferences _prefs;
  static const _key = 'pin_keyboard_type';

  PinKeyboardTypeRepoImpl(this._prefs);

  @override
  PinKeyboardType getType() {
    return PinKeyboardType.fromName(_prefs.getString(_key));
  }

  @override
  Future<void> saveType(PinKeyboardType type) async {
    await _prefs.setString(_key, type.name);
  }
}
