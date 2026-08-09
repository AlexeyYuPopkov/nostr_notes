import 'package:flutter/services.dart';

/// Per-field input formatters for the login item form.
///
/// The length caps are not cosmetic: the whole item is serialized and
/// NIP-44-encrypted into a single event payload, and NIP-44 v2 rejects
/// plaintext over 65535 bytes (relays additionally drop oversized events).
/// The caps keep the total comfortably below that even in multi-byte
/// scripts.
abstract final class LoginItemFormFormatters {
  static const maxShortFieldLength = 256;
  static const maxPasswordLength = 1024;
  static const maxNotesLength = 10000;

  static final title = <TextInputFormatter>[
    LengthLimitingTextInputFormatter(maxShortFieldLength),
  ];

  static final website = <TextInputFormatter>[
    // Whitespace is never valid inside a URL.
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
    LengthLimitingTextInputFormatter(maxShortFieldLength),
  ];

  static final username = <TextInputFormatter>[
    LengthLimitingTextInputFormatter(maxShortFieldLength),
  ];

  static final password = <TextInputFormatter>[
    LengthLimitingTextInputFormatter(maxPasswordLength),
  ];

  static final notes = <TextInputFormatter>[
    LengthLimitingTextInputFormatter(maxNotesLength),
  ];
}
