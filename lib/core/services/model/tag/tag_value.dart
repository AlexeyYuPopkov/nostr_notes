final class TagValue {
  static const String e = 'e';
  static const String d = 'd';
  static const String p = 'p';
  static const String a = 'a';
  static const String b = 'b';
  static const String k = 'k';
  static const String t = 't';
  static const String g = 'g';
  static const String client = 'client';
  static const String sig = 'sig';

  static const String sharpK = '#k';
  static const String sharpD = '#d';

  static String createATag({
    required int kind,
    required String pubkey,
    required String dTag,
  }) {
    return '${kind.toString()}:$pubkey:$dTag';
  }
}
