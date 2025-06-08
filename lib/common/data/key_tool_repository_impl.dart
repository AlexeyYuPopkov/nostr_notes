import 'package:nostr_notes/common/domain/model/session/user_keys.dart';
import 'package:nostr_notes/common/domain/repository/key_tool_repository.dart';
import 'package:nostr_notes/core/services/key_tool/key_tool.dart';

final class KeyToolRepositoryImpl implements KeyToolRepository {
  const KeyToolRepositoryImpl();
  @override
  UserKeys getUserKeys({required String? nsec}) {
    final privateKey = KeyTool.tryDecodeNsecKeyToPrivateKey(nsec);

    if (privateKey == null || privateKey.isEmpty) {
      throw const InvalidNsecError();
    }

    final pubKey = KeyTool.tryGetPubKey(privateKey: privateKey);

    if (pubKey == null || pubKey.isEmpty) {
      throw const InvalidPubkeyError();
    }

    return UserKeys(
      publicKey: pubKey,
      privateKey: privateKey,
    );
  }
}
