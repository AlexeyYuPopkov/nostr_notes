import 'package:nostr_notes/common/domain/model/session/user_keys.dart';
import 'package:nostr_notes/common/domain/repository/key_tool_repository.dart';
import 'package:nostr_notes/services/key_tool/key_tool.dart';

final class KeyToolRepositoryImpl implements KeyToolRepository {
  const KeyToolRepositoryImpl();
  @override
  UserKeys getUserKeysWithNsec({required String? nsec}) {
    final nsecTrimmed = nsec?.trim();
    if (nsecTrimmed == null || nsecTrimmed.isEmpty) {
      throw const EmptyNsecError();
    }

    final privateKey = KeyTool.tryDecodeNsecKeyToPrivateKey(nsec);

    if (privateKey == null || privateKey.isEmpty) {
      throw const EmptyNsecError();
    }

    final pubKey = KeyTool.tryGetPubKey(privateKey: privateKey);

    if (pubKey == null || pubKey.isEmpty) {
      throw const EmptyPubkeyError();
    }

    return UserKeys(publicKey: pubKey, privateKey: privateKey);
  }

  @override
  UserKeys getUserKeysWithPrivateKey({required String? privateKey}) {
    final privateKeyTrimmed = privateKey?.trim();
    if (privateKeyTrimmed == null || privateKeyTrimmed.isEmpty) {
      throw const EmptyNsecError();
    }

    final pubKey = KeyTool.tryGetPubKey(privateKey: privateKeyTrimmed);

    if (pubKey == null || pubKey.isEmpty) {
      throw const InvalidPrivateKeyError();
    }

    return UserKeys(publicKey: pubKey, privateKey: privateKeyTrimmed);
  }

  @override
  String createSig({required String rawMessage, required String privateKey}) {
    return KeyTool.createSig(rawMessage: rawMessage, privateKey: privateKey);
  }
}
