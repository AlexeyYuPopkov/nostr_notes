import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/presentation/login_item_form/tools/login_item_form_formatters.dart';

/// Runs [formatters] over an edit the way the EditableText pipeline does:
/// in list order, each seeing the previous one's output.
String apply(
  List<TextInputFormatter> formatters,
  String newText, {
  String oldText = '',
}) {
  final oldValue = TextEditingValue(text: oldText);
  var value = TextEditingValue(text: newText);
  for (final formatter in formatters) {
    value = formatter.formatEditUpdate(oldValue, value);
  }
  return value.text;
}

void main() {
  group('LoginItemFormFormatters', () {
    test('length caps are pinned to their documented values', () {
      expect(LoginItemFormFormatters.maxShortFieldLength, 256);
      expect(LoginItemFormFormatters.maxPasswordLength, 1024);
      expect(LoginItemFormFormatters.maxNotesLength, 10000);
    });

    group('website', () {
      test('strips spaces, tabs and newlines — including from a paste', () {
        expect(
          apply(LoginItemFormFormatters.website, 'apple .com'),
          'apple.com',
        );
        expect(
          apply(LoginItemFormFormatters.website, 'apple\t.com\n'),
          'apple.com',
        );
      });

      test('truncates to the short-field cap', () {
        final text = 'a' * 300;
        expect(
          apply(LoginItemFormFormatters.website, text).length,
          LoginItemFormFormatters.maxShortFieldLength,
        );
      });
    });

    group('title', () {
      test('keeps inner whitespace', () {
        expect(apply(LoginItemFormFormatters.title, 'My Bank'), 'My Bank');
      });

      test('truncates to the short-field cap', () {
        final text = 'a' * 300;
        expect(
          apply(LoginItemFormFormatters.title, text).length,
          LoginItemFormFormatters.maxShortFieldLength,
        );
      });
    });

    group('username', () {
      test('keeps inner whitespace (legal in some systems)', () {
        expect(
          apply(LoginItemFormFormatters.username, 'John Doe'),
          'John Doe',
        );
      });

      test('truncates to the short-field cap', () {
        final text = 'a' * 300;
        expect(
          apply(LoginItemFormFormatters.username, text).length,
          LoginItemFormFormatters.maxShortFieldLength,
        );
      });
    });

    group('password', () {
      test('preserves whitespace anywhere — may be intentional', () {
        expect(apply(LoginItemFormFormatters.password, ' p a s s '), ' p a s s ');
      });

      test('truncates to the password cap', () {
        final text = 'a' * 1100;
        expect(
          apply(LoginItemFormFormatters.password, text).length,
          LoginItemFormFormatters.maxPasswordLength,
        );
      });
    });

    group('notes', () {
      test('preserves newlines', () {
        expect(
          apply(LoginItemFormFormatters.notes, 'line1\nline2'),
          'line1\nline2',
        );
      });

      test('truncates to the notes cap', () {
        final text = 'a' * 10001;
        expect(
          apply(LoginItemFormFormatters.notes, text).length,
          LoginItemFormFormatters.maxNotesLength,
        );
      });
    });
  });
}
