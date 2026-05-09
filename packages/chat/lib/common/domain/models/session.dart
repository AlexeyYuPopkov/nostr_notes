import 'package:equatable/equatable.dart';
import 'package:nostr/model/user_keys.dart';

sealed class Session extends Equatable {
  const Session();

  const factory Session.unauth() = Unauth;
  const factory Session.auth(UserKeys keys) = Auth;

  UserKeys? get keys;
  String get pubkey => keys?.publicKey ?? '';
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
}
