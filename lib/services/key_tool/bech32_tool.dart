import 'package:bech32/bech32.dart';
import 'package:hex/hex.dart';

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
    return [HEX.encode(eightBitWords), bech32.hrp];
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
