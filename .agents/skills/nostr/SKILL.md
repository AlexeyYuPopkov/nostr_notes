---
name: nostr
description: Project rules for Nostr protocol code — event kinds, tags, relay messages, NIP-44 encryption, NIP-57 zaps, key handling. Use when creating, parsing, signing, encrypting or publishing Nostr events, building relay filters/subscriptions, adding a new event kind, or touching zap, key or bech32 logic in packages/nostr, packages/notes or packages/chat.
---

# Nostr in this repo

## Where things live
- Protocol layer: `packages/nostr` — `NostrClient`, `NostrRelay`, `NostrEvent`, `NostrFilter`, `NostrReq`, EOSE/OK/CLOSE models, `UserKeys`, `Bech32Tool`/`KeyTool`.
- Event kinds: `NostrKind` in `packages/notes/lib/core/event_kind.dart`. Never use a bare integer for a kind — add a constant there.
- Crypto (secp256k1 signing, NIP-44): `CryptoService` in `packages/notes/lib/services/crypto_service/` (FFI on mobile/macOS, separate web impl).
- Publishing: `OutboxPublisher` — events go through the persisted outbox queue, not straight to a relay.

## Kinds used
| Kind | Constant | Meaning |
|---|---|---|
| 0 | `NostrKind.user` | Metadata |
| 5 | `NostrKind.deletion` | Deletion (NIP-09) |
| 9734 | `NostrKind.zapInvoice` | Zap request (NIP-57) |
| 9735 | `NostrKind.zapConfirmation` | Zap receipt (NIP-57) |
| 30023 | `NostrKind.note` | Note, addressable (NIP-33) |
| 31023 | `NostrKind.loginItem` | Login item, custom addressable kind, authored by the vault identity — never the account pubkey |

Before adding a kind, check the registry: https://github.com/nostr-protocol/nips/blob/master/README.md

## Tags
- `p` pubkey, `e` event id, `a` addressable event (`<kind>:<pubkey>:<d>`), `d` identifier of an addressable event.
- Addressable events (30000–39999) are replaced by `kind + pubkey + d`; changing `d` creates a new event, it does not update the old one.

## Relays (NIP-01)
- `REQ` to subscribe, `CLOSE` to stop; always close subscriptions you open.
- `EOSE` separates stored events from live ones — don't treat "no events before EOSE" as an error.
- Assume several relays: dedupe by event id, tolerate one relay being down (`RelayUnreachable`, `RelayHealth`).
- Keep `NostrFilter` narrow (`kinds`, `authors`, `#d`, `since`, `limit`) to reduce relay load.

## Encryption and keys
- Use NIP-44 for encrypted content;
- Keys come from `SessionUsecase` / `UserKeys`. Never pass a private key as a plain string through UI, logs or analytics.
- `bech32` (`npub`, `nsec`, `note`, `nprofile`) only at the UI boundary; hex internally.
- Verify event id and signature before trusting or storing an event from a relay.

## Zaps (NIP-57)
- Code: `packages/common/lib/data/zap/` — `PerformLightingInvoiceService` builds the request, `ZapConfirmationDto` parses the receipt.
- Zap request (9734) must carry `p` (recipient), `relays`, `amount` (millisats), `lnurl`, and the `client` tag with `AppConfig.clientTagValue`.
- Zap receipt (9735) embeds the original request in `description`; read the amount from there, not from the invoice text. The spec also defines `P` (sender) and `bolt11` on the receipt.
- Spec: https://github.com/nostr-protocol/nips/blob/master/57.md
