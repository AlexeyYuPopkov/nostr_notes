import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/error/error_messages_provider.dart';
import 'package:nostr_notes/common/domain/model/session/user_keys.dart';

abstract class KeyToolRepository {
  UserKeys getUserKeysWithNsec({required String? nsec});
  UserKeys getUserKeysWithPrivateKey({required String? privateKey});
}

abstract class KeysError extends AppError {
  const KeysError({required super.reason});
}

final class EmptyNsecError extends KeysError {
  const EmptyNsecError() : super(reason: 'Nsec cannot be empty');

  @override
  String get message => ErrorMessagesProvider.defaultProvider.emptyNsec;
}

final class InvalidNsecError extends KeysError {
  const InvalidNsecError() : super(reason: 'Invalid NSEC key format');

  @override
  String get message => ErrorMessagesProvider.defaultProvider.invalidNsecFormat;
}

final class InvalidPrivateKeyError extends KeysError {
  const InvalidPrivateKeyError() : super(reason: 'Invalid private key');

  @override
  String get message => ErrorMessagesProvider.defaultProvider.emptyPubkey;
}

final class EmptyPubkeyError extends KeysError {
  const EmptyPubkeyError() : super(reason: 'Public key cannot be empty');

  @override
  String get message => ErrorMessagesProvider.defaultProvider.emptyPubkey;
}
