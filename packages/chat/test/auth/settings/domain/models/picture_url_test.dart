import 'package:chat/auth/settings/domain/models/picture_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PictureUrl.isValidOrEmpty', () {
    test('an empty value means "no picture" and is valid', () {
      expect(PictureUrl.isValidOrEmpty(''), isTrue);
      expect(PictureUrl.isValidOrEmpty('   '), isTrue);
    });

    test('accepts absolute https and http links', () {
      expect(
        PictureUrl.isValidOrEmpty('https://example.com/a.jpg?size=96'),
        isTrue,
      );
      expect(PictureUrl.isValidOrEmpty('http://example.com/a.png'), isTrue);
      expect(PictureUrl.isValidOrEmpty('  HTTPS://example.com/a.png '), isTrue);
    });

    test('rejects a link without a scheme or host', () {
      expect(PictureUrl.isValidOrEmpty('example.com/a.jpg'), isFalse);
      expect(PictureUrl.isValidOrEmpty('https://'), isFalse);
      expect(PictureUrl.isValidOrEmpty('/images/a.jpg'), isFalse);
    });

    test('rejects other schemes', () {
      expect(PictureUrl.isValidOrEmpty('ftp://example.com/a.jpg'), isFalse);
      expect(PictureUrl.isValidOrEmpty('data:image/png;base64,AAAA'), isFalse);
      expect(PictureUrl.isValidOrEmpty('javascript:alert(1)'), isFalse);
    });

    test('rejects text with spaces inside', () {
      expect(
        PictureUrl.isValidOrEmpty('https://example.com/my pic.jpg'),
        isFalse,
      );
      expect(PictureUrl.isValidOrEmpty('not a link'), isFalse);
    });
  });
}
