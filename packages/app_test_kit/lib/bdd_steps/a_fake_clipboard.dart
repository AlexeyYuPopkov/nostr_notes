import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: a fake clipboard
///
/// Widget tests have no platform clipboard, so `Clipboard.setData` would go
/// nowhere. This keeps the copied text in memory, where `Clipboard.getData`
/// reads it back. Every other platform call keeps its default `null` reply:
/// [SystemChannels.platform] is an optional channel.
Future<void> aFakeClipboard(WidgetTester tester) async {
  String? copied;
  final messenger = tester.binding.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    switch (call.method) {
      case 'Clipboard.setData':
        final arguments = call.arguments as Map<Object?, Object?>;
        copied = arguments['text'] as String?;
      case 'Clipboard.getData':
        return copied == null ? null : {'text': copied};
      case 'Clipboard.hasStrings':
        return {'value': copied?.isNotEmpty ?? false};
    }
    return null;
  });
  addTearDown(
    () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
  );
}
