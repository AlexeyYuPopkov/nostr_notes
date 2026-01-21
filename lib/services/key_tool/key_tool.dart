import 'dart:math';

import 'package:bip340/bip340.dart' as bip340;
import 'package:convert/convert.dart';
import 'package:bech32/bech32.dart';

import 'bech32_tool.dart';
import 'package:hex/hex.dart';

final class KeyTool {
  static const String nsecPrefix = 'nsec';
  static const String npubPrefix = 'npub';
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

  /// Derives the nsec key from the given private key (hex).
  static String nsecKey(String privateKey) {
    return encodeBech32(privateKey, nsecPrefix);
  }

  /// Derives the npub key from the given public key (hex).
  static String npubKey(String publicKey) {
    return encodeBech32(publicKey, npubPrefix);
  }

  static String decodeNpubKeyToPublicKey(String npubKey) {
    assert(npubKey.startsWith(npubPrefix));

    final decodedKeyComponents = decodeBech32(npubKey);

    return decodedKeyComponents.first;
  }

  /// Encodes a [hex] string into a bech32 string with a [hrp] human readable part.
  ///
  /// ```dart
  /// final npubString = Nostr.instance.services.keys.encodeBech32(yourHexString, 'npub');
  /// print(npubString); // ...
  /// ```
  static String encodeBech32(String hex, String hrp) {
    final bytes = HEX.decode(hex);
    final fiveBitWords = _convertBits(bytes, 8, 5, true);

    return bech32.encode(Bech32(hrp, fiveBitWords), hex.length + hrp.length);
  }

  /// Decodes a bech32 string into a [hex] string and a [hrp] human readable part.
  ///
  /// ```dart
  /// final decodedHexString = Nostr.instance.services.keys.decodeBech32(npubString);
  /// print(decodedHexString); // ...
  /// ```
  static List<String> decodeBech32(String bech32String) {
    const codec = Bech32Codec();
    final bech32 = codec.decode(bech32String, bech32String.length);
    final eightBitWords = _convertBits(bech32.data, 5, 8, false);
    return [HEX.encode(eightBitWords), bech32.hrp];
  }

  /// Convert bits from one base to another
  /// [data] - the data to convert
  /// [fromBits] - the number of bits per input value
  /// [toBits] - the number of bits per output value
  /// [pad] - whether to pad the output if there are not enough bits
  /// If pad is true, and there are remaining bits after the conversion, then the remaining bits are left-shifted and added to the result
  /// [return] - the converted data
  static List<int> _convertBits(
    List<int> data,
    int fromBits,
    int toBits,
    bool pad,
  ) {
    var acc = 0;
    var bits = 0;
    final result = <int>[];

    for (final value in data) {
      acc = (acc << fromBits) | value;
      bits += fromBits;

      while (bits >= toBits) {
        bits -= toBits;
        result.add((acc >> bits) & ((1 << toBits) - 1));
      }
    }

    if (pad) {
      if (bits > 0) {
        result.add((acc << (toBits - bits)) & ((1 << toBits) - 1));
      }
    } else if (bits >= fromBits || (acc & ((1 << bits) - 1)) != 0) {
      throw Exception('Invalid padding');
    }

    return result;
  }
}
