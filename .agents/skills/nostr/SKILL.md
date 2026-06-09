# Nostr Protocol Development Skill

This skill provides comprehensive instructions for developing Nostr-based applications, following NIP (Nostr Implementation Possibilities) specifications.

## Core Principles
1. **Event-Driven**: Everything in Nostr is an event (`NostrEvent`).
2. **Cryptographic Integrity**: Events must be signed with `secp256k1` and have valid `id` hashes.
3. **Decentralization**: Always design for multi-relay environments.

## Implementation Guidelines

### Event Structure (NIP-01) use the following guidelines:
```
https://github.com/nostr-protocol/nips/blob/master/01.md
```
- **Kind**: Use proper integers for event types (e.g., 0: Metadata, 5: Deletion event, 9734: Zap invoice, 9735: Zap Confirmation).
- **Custom Kinds in the codebase**: 30023: note (addressable event).
- **Tags**: 
  - `p` for pubkeys.
  - `e` for event IDs.
  - `a` for addressable events (NIP-33).
  - `d` for identifier tags.

### Zaps (NIP-57) use the following guidelines:
```
  https://github.com/nostr-protocol/nips/blob/master/57.md
```

### Relays & Communication
- Use `REQ` to subscribe to events and `CLOSE` to stop subscriptions.
- Handle `EOSE` (End of Stored Events) to distinguish between historical and real-time events.
- Implement proper reconnection logic for WebSockets.

### Cryptography
- Prefer `NIP-44` for encryption over `NIP-04` where supported.
- Never expose private keys in UI or logs.

## Best Practices
- **Validation**: Always verify event signatures before processing or storing.
- **Filtering**: Use specific `NostrFilter` parameters to reduce relay load and bandwidth.
- **Encoding**: Use `bech32` (npub, nsec, note, nprofile) for user-facing strings and `hex` for internal processing.

## To find which NIPs document a specific event kind use
  ```
  https://github.com/nostr-protocol/nips/blob/master/README.md
  ```