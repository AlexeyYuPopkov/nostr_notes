import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/services/key_tool/key_tool.dart';

void main() {
  group('KeyTool', () {
    const nsecKey =
        'nsec1eqxnyetjwh98dzwmg8skkge7avsuxtgjq00mcgc9l3ypf9txy4kqze6uds';
    const privateKey =
        'c80d32657275ca7689db41e16b233eeb21c32d1203dfbc2305fc48149566256c';
    const publicKey =
        '5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee';
    test('[tryDecodeNsecKeyToPrivateKey]. Returns null for wrong input', () {
      expect(KeyTool.tryDecodeNsecKeyToPrivateKey(null), isNull);
      expect(KeyTool.tryDecodeNsecKeyToPrivateKey(''), isNull);
      expect(KeyTool.tryDecodeNsecKeyToPrivateKey('123'), isNull);
      expect(
        KeyTool.tryDecodeNsecKeyToPrivateKey(nsecKey.replaceAll('nsec', '')),
        isNull,
      );
    });
    test('[tryDecodeNsecKeyToPrivateKey]. Returns Private key', () {
      expect(
        KeyTool.tryDecodeNsecKeyToPrivateKey(nsecKey),
        privateKey,
      );
    });

    test('[tryGetPubKey]. Returns null for wrong input', () {
      expect(KeyTool.tryGetPubKey(privateKey: null), isNull);
      expect(KeyTool.tryGetPubKey(privateKey: ''), isNull);
      expect(KeyTool.tryDecodeNsecKeyToPrivateKey('123'), isNull);
      expect(KeyTool.tryGetPubKey(privateKey: privateKey.substring(1)), isNull);
    });

    test('[tryGetPubKey]. Returns Public key', () {
      expect(
        KeyTool.tryGetPubKey(privateKey: privateKey),
        publicKey,
      );
    });
  });
}
