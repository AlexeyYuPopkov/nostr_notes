import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/presentation/edit_note_markdown_screen/tools/edit_note_formatters.dart';
import 'package:nostr_notes/auth/presentation/tools/utf8_length_limiting_text_input_formatter.dart';

void main() {
  group('EditNoteFormatters', () {
    test('content cap is pinned to the NIP-44 plaintext limit', () {
      expect(EditNoteFormatters.maxContentBytes, 65535);
    });

    test('content is guarded by the byte-aware formatter with that cap', () {
      expect(EditNoteFormatters.content, hasLength(1));
      final formatter = EditNoteFormatters.content.single;
      expect(formatter, isA<Utf8LengthLimitingTextInputFormatter>());
      expect(
        (formatter as Utf8LengthLimitingTextInputFormatter).maxBytes,
        EditNoteFormatters.maxContentBytes,
      );
    });
  });
}
