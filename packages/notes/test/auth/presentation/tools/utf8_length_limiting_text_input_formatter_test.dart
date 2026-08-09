import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/presentation/tools/utf8_length_limiting_text_input_formatter.dart';

void main() {
  TextEditingValue value(String text) => TextEditingValue(text: text);

  TextEditingValue format(
    Utf8LengthLimitingTextInputFormatter formatter,
    String oldText,
    String newText,
  ) {
    return formatter.formatEditUpdate(value(oldText), value(newText));
  }

  group('Utf8LengthLimitingTextInputFormatter', () {
    test('accepts text under the limit', () {
      const formatter = Utf8LengthLimitingTextInputFormatter(10);
      expect(format(formatter, '', 'abc').text, 'abc');
    });

    test('accepts text exactly at the byte limit', () {
      const formatter = Utf8LengthLimitingTextInputFormatter(3);
      expect(format(formatter, '', 'abc').text, 'abc');
    });

    test('rejects ASCII text over the limit, keeping the old value', () {
      const formatter = Utf8LengthLimitingTextInputFormatter(3);
      expect(format(formatter, 'abc', 'abcd').text, 'abc');
    });

    test('counts bytes, not characters: Cyrillic is 2 bytes per char', () {
      const formatter = Utf8LengthLimitingTextInputFormatter(4);
      // 2 chars * 2 bytes = 4 bytes — fits.
      expect(format(formatter, '', 'аб').text, 'аб');
      // 3 chars * 2 bytes = 6 bytes — over, though only 3 UTF-16 units.
      expect(format(formatter, 'аб', 'абв').text, 'аб');
    });

    test('counts astral-plane chars by their UTF-8 size (4 bytes)', () {
      const formatter = Utf8LengthLimitingTextInputFormatter(4);
      expect(format(formatter, '', '😀').text, '😀');
      expect(format(formatter, '😀', '😀a').text, '😀');
    });

    test(
      'rejects rather than truncates: an oversized paste leaves text as-is',
      () {
        const formatter = Utf8LengthLimitingTextInputFormatter(8);
        final result = format(formatter, 'short', 'a' * 100);
        expect(result.text, 'short');
      },
    );

    test('fast path: long ASCII text under the limit is accepted', () {
      // length * 3 > maxBytes forces the exact utf8 count, which passes.
      const formatter = Utf8LengthLimitingTextInputFormatter(100);
      final text = 'a' * 90;
      expect(format(formatter, '', text).text, text);
    });
  });
}
