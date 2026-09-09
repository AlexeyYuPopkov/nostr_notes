import 'dart:async';

import 'package:flutter/services.dart';

final class ClipboardHelper {
  static const instance = ClipboardHelper._();

  const ClipboardHelper._();

  Future<void> setData(
    String text, {
    Duration? cleanAfter = const Duration(seconds: 60),
  }) async {
    if (cleanAfter != null) {
      unawaited(_clearAfter(text, cleanAfter));
    }

    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Whether the clipboard still carries exactly what we last put there.
  /// Guards every overwrite: anything the user copied in the meantime is
  /// theirs, and replacing it would lose data they meant to keep.
  Future<bool> holds(String text) async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      return clipboardData?.text == text;
    } catch (_) {
      return false;
    }
  }

  Future<void> _clearAfter(String text, Duration cleanAfter) async {
    await Future.delayed(cleanAfter);
    if (await holds(text)) {
      await Clipboard.setData(const ClipboardData(text: ''));
    }
  }
}
