import 'package:bech32/bech32.dart';

import '../hex/hex.dart';

final class Bech32hex {
  final String hrp;
  final String data;

  Bech32hex({required this.hrp, required this.data});
}

final class Bech32bytes {
  final String hrp;
  final List<int> data;

  Bech32bytes({required this.hrp, required this.data});
}

final class Bech32Tool {
  static List<String> decodeBech32(String bech32String) {
    const codec = Bech32Codec();
    final bech32 = codec.decode(bech32String, bech32String.length);
    final eightBitWords = _convertBits(
      data: bech32.data,
      fromBits: 5,
      toBits: 8,
      pad: false,
    );
    return [HexCodec.hex.encode(eightBitWords), bech32.hrp];
  }

  static Bech32hex decode(String bech32String) {
    final bech32 = decodeBytes(bech32String);
    return Bech32hex(hrp: bech32.hrp, data: HexCodec.hex.encode(bech32.data));
  }

  static Bech32bytes decodeBytes(String bech32String) {
    const codec = Bech32Codec();
    final bech32 = codec.decode(bech32String, bech32String.length);
    final eightBitWords = _convertBits(
      data: bech32.data,
      fromBits: 5,
      toBits: 8,
      pad: false,
    );
    return Bech32bytes(hrp: bech32.hrp, data: eightBitWords);
  }

  static String encodeBech32(String hrp, String hex, {int? maxLength}) {
    final bytes = HexCodec.hex.decode(hex);
    return encodeBech32FromBytes(hrp, bytes);
  }

  static String encodeBech32FromBytes(
    String hrp,
    List<int> bytes, {
    int? maxLength,
  }) {
    final fiveBitWords = _convertBits(
      data: bytes,
      fromBits: 8,
      toBits: 5,
      pad: true,
    );

    return bech32.encode(
      Bech32(hrp, fiveBitWords),
      maxLength ?? (bytes.length * 2 + hrp.length),
    );
  }

  /// Convert bits from one base to another
  /// [data] - the data to convert
  /// [fromBits] - the number of bits per input value
  /// [toBits] - the number of bits per output value
  /// [pad] - whether to pad the output if there are not enough bits
  /// If pad is true, and there are remaining bits after the conversion, then the remaining bits are left-shifted and added to the result
  /// [return] - the converted data
  static List<int> _convertBits({
    required List<int> data,
    required int fromBits,
    required int toBits,
    required bool pad,
  }) {
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
      throw const Bech32ToolException('Invalid padding');
    }

    return result;
  }
}

final class Bech32ToolException implements Exception {
  final String message;

  const Bech32ToolException(this.message);
}
