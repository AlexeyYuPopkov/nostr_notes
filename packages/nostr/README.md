# packages/nostr — Nostr Protocol Library

Pure Dart Nostr protocol library. No UI, no app-specific logic. Used by `packages/notes` and `packages/chat`.

---

## Contents

```
lib/
  model/          ← Event models (NostrEvent, NostrFilter, UserKeys, tags, …)
  nostr_client/   ← NostrClient, NostrRelay, NostrPublisher, relay monitoring
  key_tool/       ← Key derivation and conversion utilities
  hex/            ← Hex encoding/decoding
```

**Key types**

| Type | Description |
|------|-------------|
| `NostrClient` | Manages connections to multiple relays; subscribe/publish |
| `NostrRelay` | Single relay connection (WebSocket, reconnect logic) |
| `NostrEvent` | Signed Nostr event (kind, content, tags, sig) |
| `NostrFilter` / `NostrReq` | Subscription filters (REQ) |
| `UserKeys` | Public/private keypair wrapper |
| `NostrEventCreator` | Builds and signs events |
| `PublishEventReport` | Result of a publish operation per relay |

---

## Codegen

Some models use `json_serializable`. After changing annotated classes:

```bash
make codegen   # from repo root
```
