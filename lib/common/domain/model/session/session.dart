import 'package:equatable/equatable.dart';
import 'package:nostr_notes/common/domain/model/session/user_keys.dart';

sealed class Session extends Equatable {
  const Session();

  const factory Session.unauth() = Unauth;
  const factory Session.auth(UserKeys keys) = Auth;
  const factory Session.unlocked(
      {required UserKeys keys, required String pin}) = Unlocked;

  UserKeys? get keys;
  bool get isAuth;
  bool get isUnlocked;
}

final class Unauth extends Session {
  @override
  final UserKeys? keys = null;

  const Unauth();

  @override
  bool get isAuth => false;

  @override
  bool get isUnlocked => false;

  @override
  List<Object?> get props => [];

  Auth toAuth({required UserKeys keys}) {
    return Auth(keys);
  }
}

final class Auth extends Session {
  @override
  final UserKeys keys;

  const Auth(this.keys);

  @override
  bool get isAuth => true;

  @override
  bool get isUnlocked => false;

  @override
  List<Object?> get props => [keys];

  Unlocked toUnlocked({required String pin}) {
    return Unlocked(keys: keys, pin: pin);
  }
}

final class Unlocked extends Session {
  @override
  final UserKeys keys;
  final String pin;

  const Unlocked({required this.keys, required this.pin});

  @override
  bool get isAuth => true;

  @override
  bool get isUnlocked => true;

  @override
  List<Object?> get props => [keys, pin];
}
