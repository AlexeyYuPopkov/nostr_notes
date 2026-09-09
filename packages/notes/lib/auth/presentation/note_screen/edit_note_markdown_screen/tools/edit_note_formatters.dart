import 'package:flutter/services.dart';
import 'package:nostr_notes/auth/presentation/tools/utf8_length_limiting_text_input_formatter.dart';

/// Input formatters for the markdown note editor.
abstract final class EditNoteFormatters {
  /// NIP-44 v2 rejects plaintext over 65535 bytes (see
  /// `nip_44_utils.dart`), and the note's markdown body is encrypted
  /// verbatim as one payload — content beyond this cap could be typed but
  /// never saved.
  static const maxContentBytes = 65535;

  static const content = <TextInputFormatter>[
    Utf8LengthLimitingTextInputFormatter(maxContentBytes),
  ];
}
