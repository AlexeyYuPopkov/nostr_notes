import 'dart:typed_data';

mixin HexToBytes {
  static Uint8List hexToBytes(String src) {
    return src.hexToBytes();
  }

  static String bytesToHex(Uint8List bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

extension on String {
  Uint8List hexToBytes() {
    final theLength = length;
    final result = Uint8List(theLength ~/ 2);
    for (int i = 0; i < theLength; i += 2) {
      result[i ~/ 2] = int.parse(substring(i, i + 2), radix: 16);
    }
    return result;
  }
}
