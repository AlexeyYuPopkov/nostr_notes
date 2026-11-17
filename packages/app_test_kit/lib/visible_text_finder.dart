import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Text a user can actually read. Unlike `find.text`, an obscured field does
/// not count: it renders dots while its controller still holds the value.
Finder findVisibleText(String text) {
  return find.byWidgetPredicate(
    (widget) => switch (widget) {
      Text(:final data, :final textSpan) =>
        (data ?? textSpan?.toPlainText()) == text,
      EditableText(:final obscureText, :final controller) =>
        !obscureText && controller.text == text,
      _ => false,
    },
    description: 'visible text "$text"',
  );
}
