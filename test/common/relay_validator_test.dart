import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/common/domain/relay_validator.dart';

final class _Sut with RelayValidator {}

void main() {
  late _Sut sut;

  setUp(() => sut = _Sut());

  group('RelayValidator — valid URLs', () {
    test('valid URLs', () {
      final valid = [
        'wss://relay.damus.io',
        'wss://nos.lol',
        'wss://relay.nostr.band',
        'wss://relay.snort.social',
        'wss://relay.example.com:443',
        'wss://relay.example.com/path',
        'wss://relay.example.com:8080/path',
        'ws://relay.example.com',
        'ws://localhost:8008',
        'ws://localhost:3000',
        'wss://a-b.relay.example.com',
      ];

      for (final url in valid) {
        expect(sut.isValidRelayUrl(url), isTrue);
      }
    });
  });

  group('RelayValidator — invalid URLs', () {
    test('invalid URLs', () {
      final invalid = [
        '',
        'relay.damus.io',
        'http://relay.damus.io',
        'https://relay.damus.io',
        'ftp://relay.damus.io',
        'wss://',
        'wss://relay',
        'wss:// relay.damus.io',
        'wss://user:pass@relay.damus.io',
        'ws://localhost',
        'ws://localhost:',
        'ws://localhost:999999',
        'wss://.relay.com',
        'wss://relay..com',
        'wss://-relay.com',
      ];
      for (final url in invalid) {
        expect(sut.isValidRelayUrl(url), isFalse);
      }
    });
  });
}
