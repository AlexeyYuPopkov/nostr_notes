import 'package:nostr_notes/common/domain/model/pin_keyboard_type.dart';

abstract interface class PinKeyboardTypeRepo {
  PinKeyboardType getType();
  Future<void> saveType(PinKeyboardType type);
}
