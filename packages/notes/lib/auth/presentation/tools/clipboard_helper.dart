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

  Future<void> _clearAfter(String text, Duration cleanAfter) async {
    await Future.delayed(cleanAfter);
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text == text) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    } catch (_) {}
  }
}
