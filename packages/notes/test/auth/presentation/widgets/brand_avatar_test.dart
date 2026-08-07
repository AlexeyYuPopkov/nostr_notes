import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/app/icons/accs_icons.dart';
import 'package:nostr_notes/auth/presentation/widgets/brand_avatar.dart';

final class _Harness with BrandAvatarHelper {}

void main() {
  late _Harness helper;

  setUp(() {
    helper = _Harness();
  });

  group('matchBrandIcon — website takes priority', () {
    test('matches a bare domain', () {
      expect(
        helper.matchBrandIcon(website: 'google.com', title: 'Mail'),
        AccsIcons.google,
      );
    });

    test('strips scheme, www, path, query and fragment', () {
      expect(
        helper.matchBrandIcon(
          website: 'https://www.aliexpress.com/item/123?x=1#f',
          title: '',
        ),
        AccsIcons.aliexpress,
      );
    });

    test('is case-insensitive against a slug with internal capitals', () {
      // The catalog's own key is `linkedIn` (capital I).
      expect(
        helper.matchBrandIcon(website: 'https://www.LinkedIn.com/', title: ''),
        AccsIcons.linkedIn,
      );
    });

    test('falls back to title when the website has no catalog match', () {
      expect(
        helper.matchBrandIcon(website: 'https://my-internal-tool.example', title: 'PayPal'),
        AccsIcons.paypal,
      );
    });
  });

  group('matchBrandIcon — title fallback', () {
    test('normalizes punctuation and casing', () {
      expect(
        helper.matchBrandIcon(website: '', title: '1Password'),
        AccsIcons.onePassword,
      );
    });

    test('strips spaces, so a multi-word title still matches', () {
      expect(
        helper.matchBrandIcon(website: '', title: '  Ali Express  '),
        AccsIcons.aliexpress,
      );
    });

    test('exact single-word brand name matches', () {
      expect(
        helper.matchBrandIcon(website: '', title: 'coinbase'),
        AccsIcons.coinbase,
      );
    });
  });

  group('matchBrandIcon — no match', () {
    test('returns null for unrelated website and title', () {
      expect(
        helper.matchBrandIcon(
          website: 'https://not-a-known-brand.example',
          title: 'Some Random Account',
        ),
        isNull,
      );
    });

    test('returns null for empty website and title', () {
      expect(helper.matchBrandIcon(website: '', title: ''), isNull);
    });

    test('a single-label host (no TLD) is used as-is and still may miss', () {
      expect(
        helper.matchBrandIcon(website: 'localhost', title: ''),
        isNull,
      );
    });
  });

  group('avatarColor', () {
    test('is deterministic for the same seed', () {
      expect(helper.avatarColor('Google'), helper.avatarColor('Google'));
    });

    test('produces a fully opaque color', () {
      expect(helper.avatarColor('anything').a, 1.0);
    });
  });
}
