import 'dart:convert';

import 'package:flutter/services.dart';

/// Rejects edits that would push the text's UTF-8 byte length over
/// [maxBytes].
///
/// Unlike [LengthLimitingTextInputFormatter] (which counts UTF-16 code
/// units), this enforces the limit that actually matters for NIP-44
/// encrypted payloads — the spec caps plaintext at 65535 *bytes*, and e.g.
/// Cyrillic text costs two bytes per character. Oversized edits are
/// rejected outright rather than truncated, so a paste can never silently
/// cut existing content mid-way.
final class Utf8LengthLimitingTextInputFormatter extends TextInputFormatter {
  final int maxBytes;

  const Utf8LengthLimitingTextInputFormatter(this.maxBytes);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // UTF-8 never needs more than 3 bytes per UTF-16 code unit (BMP chars
    // are ≤3 bytes for one unit; astral chars are 4 bytes for two), so
    // short texts skip the exact encode entirely.
    if (newValue.text.length * 3 <= maxBytes) {
      return newValue;
    }
    if (utf8.encode(newValue.text).length <= maxBytes) {
      return newValue;
    }
    return oldValue;
  }
}
