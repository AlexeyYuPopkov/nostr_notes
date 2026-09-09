import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/presentation/login_item_form/tools/login_item_form_normalization.dart';

final class _Harness with LoginItemFormNormalization {}

void main() {
  late _Harness helper;

  setUp(() {
    helper = _Harness();
  });

  group('normalizedWebsiteUrl', () {
    test('empty and whitespace-only input stays empty', () {
      expect(helper.normalizedWebsiteUrl(''), '');
      expect(helper.normalizedWebsiteUrl('   '), '');
    });

    test('prepends https:// to a bare domain', () {
      expect(helper.normalizedWebsiteUrl('apple.com'), 'https://apple.com');
    });

    test('trims before prefixing', () {
      expect(helper.normalizedWebsiteUrl('  apple.com  '), 'https://apple.com');
    });

    test('keeps an explicit https/http scheme unchanged', () {
      expect(
        helper.normalizedWebsiteUrl('https://apple.com'),
        'https://apple.com',
      );
      expect(
        helper.normalizedWebsiteUrl('http://apple.com'),
        'http://apple.com',
      );
    });

    test('host:port gets the prefix despite parsing as a URI scheme', () {
      // Uri.hasScheme is true here ("apple.com" is a valid scheme token),
      // which is exactly why normalization checks for `://` instead.
      expect(
        helper.normalizedWebsiteUrl('apple.com:8080'),
        'https://apple.com:8080',
      );
    });

    test('a path and query survive prefixing', () {
      expect(
        helper.normalizedWebsiteUrl('apple.com/store?item=1'),
        'https://apple.com/store?item=1',
      );
    });

    test('a non-http scheme with :// passes through unchanged', () {
      expect(
        helper.normalizedWebsiteUrl('ftp://files.example'),
        'ftp://files.example',
      );
    });
  });

  group('deriveTitle', () {
    test('an explicit title wins and is trimmed', () {
      expect(
        helper.deriveTitle(
          title: '  My Bank  ',
          websiteUrl: 'https://bank.example',
          username: 'user',
        ),
        'My Bank',
      );
    });

    test('whitespace-only title falls back to the website host', () {
      expect(
        helper.deriveTitle(
          title: '   ',
          websiteUrl: 'https://developer.apple.com',
          username: 'user',
        ),
        'developer.apple.com',
      );
    });

    test('strips a www. prefix from the host', () {
      expect(
        helper.deriveTitle(
          title: '',
          websiteUrl: 'https://www.apple.com/store',
          username: 'user',
        ),
        'apple.com',
      );
    });

    test('drops the port from the derived title', () {
      expect(
        helper.deriveTitle(
          title: '',
          websiteUrl: 'https://apple.com:8080',
          username: 'user',
        ),
        'apple.com',
      );
    });

    test('no website host falls back to the trimmed username', () {
      expect(
        helper.deriveTitle(
          title: '',
          websiteUrl: '',
          username: '  user@example.com  ',
        ),
        'user@example.com',
      );
    });

    test('an unnormalized scheme-less website has no host — username wins', () {
      // Documents the contract: deriveTitle expects an already-normalized
      // URL; a bare domain parses without a host.
      expect(
        helper.deriveTitle(
          title: '',
          websiteUrl: 'apple.com',
          username: 'user',
        ),
        'user',
      );
    });

    test('everything blank derives an empty title', () {
      expect(helper.deriveTitle(title: '', websiteUrl: '', username: ''), '');
    });
  });
}
