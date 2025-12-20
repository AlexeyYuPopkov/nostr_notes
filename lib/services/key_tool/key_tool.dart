import 'dart:math';

import 'package:bip340/bip340.dart' as bip340;
import 'package:convert/convert.dart';

import 'bech32_tool.dart';

final class KeyTool {
  static const String nsecPrefix = 'nsec';
  static const privateKeyLength = 64;
  static const minPossibleNsecLength = 10;

  static String? tryDecodeNsecKeyToPrivateKey(String? nsecKey) {
    if (nsecKey == null || nsecKey.isEmpty || !nsecKey.startsWith(nsecPrefix)) {
      return null;
    }

    if (nsecKey.length < minPossibleNsecLength) {
      return null;
    }

    return _decodeNsecKeyToPrivateKey(nsecKey);
  }

  static String? tryGetPubKey({required String? privateKey}) {
    if (privateKey == null || privateKey.isEmpty) {
      return null;
    }

    if (privateKey.length != privateKeyLength) {
      return null;
    }

    try {
      final result = bip340.getPublicKey(privateKey);
      return result;
    } catch (e) {
      return null;
    }
  }

  static String createSig({
    required String rawMessage,
    required String privateKey,
    List<int>? randomBytes,
  }) {
    final aux = random64HexChars(randomBytes: randomBytes);
    return bip340.sign(privateKey, rawMessage, aux);
  }

  static String random64HexChars({List<int>? randomBytes}) {
    final bytes = randomBytes ?? _generateRandomBytes(32);
    assert(bytes.length == 32, 'Random bytes should be exactly 32 bytes long');
    return hex.encode(bytes);
  }

  static List<int> _generateRandomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (i) => random.nextInt(256));
  }

  static String _decodeNsecKeyToPrivateKey(String nsecKey) {
    assert(nsecKey.startsWith(nsecPrefix));
    final decodedKeyComponents = Bech32Tool.decodeBech32(nsecKey);
    return decodedKeyComponents.first;
  }
}
