# Private Notes (Nostr) — Monorepo

End-to-end encrypted notes app built on the [Nostr](https://nostr.com) protocol. Notes are encrypted on-device with NIP-44, signed with secp256k1, and stored on user-selected relays. No server, no accounts — only a keypair.

**Platforms:** iOS · Android · macOS · Web

---

## Packages

| Package | Description |
|---------|-------------|
| [`packages/notes`](packages/notes/) | Main app — the production Notes application |
| [`packages/common`](packages/common/) | Shared UI components, theme, database (drift), l10n utilities |
| [`packages/nostr`](packages/nostr/) | Pure Nostr protocol library — client, relay, event models, NIPs |
| [`packages/chat`](packages/chat/) | ⚠️ Draft — Nostr-based chat app. Currently in early draft state; further development is uncertain |

## Native crypto module

`cpp/ffi/` contains a native secp256k1 crypto module (CMake). Built as an `.xcframework` for iOS/macOS and `.so` for Android. Consumed via `CryptoService` in `packages/notes`.

---

## Requirements

- **Flutter:** 3.44.0 (managed via [FVM](https://fvm.app) — use `fvm flutter` or activate the version globally)
- **Melos:** for workspace dependency management and scripts
- **Ruby / Bundler:** only required for relay management (`make relay_up`)

---

## Quick start

```bash
# Install workspace dependencies
make bootstrap       # runs: melos bootstrap

# Run all tests with coverage
make test

# Regenerate l10n after editing .arb files
make l10n

# Regenerate JSON serialization (.g.dart)
make codegen

# Build release APK
make build_apk
```

### Native FFI (secp256k1)

```bash
make ffi-ios      # builds crypto_module.xcframework for iOS
make ffi-macos    # builds crypto_module.xcframework for macOS
```

### Local relay (for integration tests)

```bash
make relay_up     # starts relay in Docker via Fastlane
make relay_down
make relay_clean
```

---

## Repository layout

```
packages/
  notes/          ← Main Flutter app
  common/         ← Shared package (no app entry point)
  nostr/          ← Protocol library (no UI)
  chat/           ← Draft app
cpp/
  ffi/            ← secp256k1 native module (CMake)
  secp256k1/      ← secp256k1 C library source
Makefile          ← All common commands
melos.yaml        ← Workspace config
```
