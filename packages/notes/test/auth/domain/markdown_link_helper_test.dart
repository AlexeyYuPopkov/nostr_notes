import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/domain/usecase/markdown_link_helper.dart';

void main() {
  group('MarkdownLinkHelper.formatBareLinks', () {
    test('returns empty string unchanged', () {
      expect(MarkdownLinkHelper.formatBareLinks(''), '');
    });

    test('URL inside single backtick inline code is not formatted', () {
      const input = 'Run `curl https://example.com` to test';
      expect(MarkdownLinkHelper.formatBareLinks(input), input);
    });

    test('URL inside triple backtick code block is not formatted', () {
      const input = '```sh\ncurl https://example.com\n```';
      expect(MarkdownLinkHelper.formatBareLinks(input), input);
    });

    // Covers: bare http/https URLs → wrapped; already-formatted [text](url) → untouched;
    // URLs inside `` ` `` and ` ``` ` code blocks → untouched;
    // trailing punctuation stripped from URL end.
    test(
      'realistic note — bare URLs wrapped, code blocks and formatted links untouched',
      () {
        expect(
          MarkdownLinkHelper.formatBareLinks(_Fixtures.realisticNote),
          _Fixtures.expectedFormattedNote,
        );
      },
    );
  });
}

final class _Fixtures {
  static const String realisticNote = '''# Nostr Protocol Research Notes

## Overview

Nostr is a simple, open protocol for global censorship-resistant networks.
The main spec lives at https://github.com/nostr-protocol/nostr and the NIPs
are tracked at https://github.com/nostr-protocol/nips.

## Key Resources

- Spec: [NIPs repo](https://github.com/nostr-protocol/nips)
- Reference client: https://github.com/fiatjaf/nostr-tools
- Good intro: `https://nostr.how/en/what-is-nostr`,
- Relay finder: [nostr.watch](https://nostr.watch)

## Setting Up a Relay

```bash
docker run -d -p 7777:7777 scsibug/nostr-rs-relay
```

Set `RELAY_URL=https://relay.damus.io` in your env before running.
The public relay endpoint is https://relay.damus.io — avoid it for testing.

## NIP-57 Zaps

Full spec: https://github.com/nostr-protocol/nips/blob/master/57.md.
Lightning invoice format: http://www.bolt11.org
Already linked in codebase: [Zap NIP](https://github.com/nostr-protocol/nips/blob/master/57.md)

## Troubleshooting

Check secp256k1 version: https://github.com/bitcoin-core/secp256k1.

```sh
# test with curl
curl https://relay.damus.io
# fallback: http://localhost:7777
```

The `Content-Type` header is ignored for websocket upgrades.''';

  static const String expectedFormattedNote = '''# Nostr Protocol Research Notes

## Overview

Nostr is a simple, open protocol for global censorship-resistant networks.
The main spec lives at [https://github.com/nostr-protocol/nostr](https://github.com/nostr-protocol/nostr) and the NIPs
are tracked at [https://github.com/nostr-protocol/nips](https://github.com/nostr-protocol/nips).

## Key Resources

- Spec: [NIPs repo](https://github.com/nostr-protocol/nips)
- Reference client: [https://github.com/fiatjaf/nostr-tools](https://github.com/fiatjaf/nostr-tools)
- Good intro: `https://nostr.how/en/what-is-nostr`,
- Relay finder: [nostr.watch](https://nostr.watch)

## Setting Up a Relay

```bash
docker run -d -p 7777:7777 scsibug/nostr-rs-relay
```

Set `RELAY_URL=https://relay.damus.io` in your env before running.
The public relay endpoint is [https://relay.damus.io](https://relay.damus.io) — avoid it for testing.

## NIP-57 Zaps

Full spec: [https://github.com/nostr-protocol/nips/blob/master/57.md](https://github.com/nostr-protocol/nips/blob/master/57.md).
Lightning invoice format: [http://www.bolt11.org](http://www.bolt11.org)
Already linked in codebase: [Zap NIP](https://github.com/nostr-protocol/nips/blob/master/57.md)

## Troubleshooting

Check secp256k1 version: [https://github.com/bitcoin-core/secp256k1](https://github.com/bitcoin-core/secp256k1).

```sh
# test with curl
curl https://relay.damus.io
# fallback: http://localhost:7777
```

The `Content-Type` header is ignored for websocket upgrades.''';
}
