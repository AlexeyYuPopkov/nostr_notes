# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

**Flutter version**: 3.44.0 (managed via FVM — use `fvm flutter` or ensure the correct version is active)

```bash
# Install dependencies (all packages via Melos)
make bootstrap          # runs: melos bootstrap

# Get deps for a single package
flutter pub get         # run inside the target package directory

# Run all tests with coverage
make test               # runs flutter test --coverage across all packages, merges lcov reports

# Run tests for a single package
cd packages/notes && flutter test

# Run a single test file
cd packages/notes && flutter test test/auth/domain/create_note_usecase_test.dart

# Codegen (build_runner, used for JSON serialization .g.dart files)
make codegen

# Regenerate l10n (run after editing .arb files)
make l10n               # requires l10n.yaml to exist in the package

# Build release APK
make build_apk

# Build native FFI crypto module for macOS
make ffi-macos

# Build native FFI crypto module for iOS
make ffi-ios

# Relay management (requires Ruby/Bundler)
make relay_up / relay_down / relay_clean

# Clean pub cache (if dart_tool issues arise)
flutter clean && flutter pub get
```

## Mono-repo Structure

This is a Melos workspace (`melos.yaml`) with these packages:

- **`packages/notes`** — Main notes app. Entry point: `lib/main.dart`. Uses `di_storage` for DI, `go_router` for routing, `flutter_bloc` + custom `Vm` (ValueNotifier-based) for state, `flutter_localizations` via `l10n/`.
- **`packages/chat`** — Chat app. Uses `get_it` for DI, `auto_route` for routing.
- **`packages/nostr`** — Pure Nostr protocol: `NostrClient`, `NostrRelay`, event models, NIP implementations.
- **`packages/common`** — Shared models, theme (`AppTheme`, `AppBackgroundColors`), `GlobalSettingsScope`/`GlobalSettingsVm`, presentation widgets, `AppDatabase` (drift/sqlite).
- **`cpp/ffi/`** — Native secp256k1 crypto module. Built as an xcframework for iOS/macOS and `.so` for Android. Consumed via `CryptoService` (abstract interface with mobile/web implementations).

## Architecture (packages/notes)

**Clean Architecture layers** within `lib/`:

```
app/          ← DI setup (Di/AppDi), router, app config
auth/
  domain/     ← Models (Note, Label), Usecase interfaces, Repository interfaces
  data/       ← Usecase/Repository implementations, mappers
  presentation/ ← Screens, Blocs, Vm (ViewModels)
common/       ← Cross-feature domain/presentation shared within the app
services/     ← CryptoService (FFI), OutboxPublisher, app workers
core/         ← NostrKind constants, low-level tools
unauth/       ← Pre-login screens (onboarding, etc.)
```

**DI lifecycle** (`app/di/`):
- `Di.instance.bindUnauthModules()` — called at startup; binds DB, crypto, preferences.
- `Di.instance.bindAuthModules()` — called when session becomes authenticated; binds Nostr client, repositories, `OutboxPublisher`.
- Scopes are removed/replaced on logout. DI uses `DiStorage.shared` (not `get_it`) for `packages/notes`.

**Routing** (`app/router/`):
- Uses `go_router`. Never call `GoRouter.of(context)` directly from UI.
- Navigation is triggered via `RouteHandler.of(context)?.onRoute(SomeRoute(), context)`.
- Route types are plain classes implementing `AppRoute` (see `settings_screen_routes.dart`).
- `AppRouter` manages the `GoRouter` instance, handles auth redirect, and refreshes on session changes.

**State management**:
- `flutter_bloc` (`Bloc`) for screen-level state (settings, credentials, donate flows).
- Bloc state classes carry a `data` field (a dedicated data class) holding the screen's content. Sealed subclasses represent transient states (`LoadingState`, `ErrorState`, `CommonState`, etc.).
- Custom `Vm extends ValueNotifier` for lightweight reactive state (e.g., `PendingVm`).

**Nostr specifics**:
- Event kinds: use `NostrKind` constants (not magic numbers). Notes are kind `30023` (NIP-33 Parameterized Replaceable Events).
- Zaps follow NIP-57: always include `p`, `P`, `description` tags and the `client` tag (`AppConfig.clientTagValue`).
- `OutboxPublisher` handles async relay publishing with outbox queue persistence.
- Keys managed through `SessionUsecase` / `UserKeys`. Never pass private keys as plain strings through UI layers.

## Code Style

- **`const`** everywhere possible — enforced by linter (`prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `prefer_const_declarations`).
- **Trailing commas** required on all multi-line argument lists and collection literals (`require_trailing_commas: true`).
- **Single quotes** for strings.
- **No `dynamic`** — create typed models or extensions instead of raw `Map<String, dynamic>`.
- Always declare return types (`always_declare_return_types`).

## Testing

**Widget tests** — wrap in `AppLauncher.launchApp(child: ..., tester: ...)` (see `test/tools/app_launcher/app_launcher.dart`) to get theme, localization, and `RootContextProvider`.

**DI in tests** — bind via `DiStorage.shared`; always clean up in `tearDown`:
```dart
tearDown(() => DiStorage.shared.removeAll());
```

**Mocking** — use `Mocktail`. In-memory DB available via `InMemoryDbModule` (re-exported from `packages/common/test/tools/di/`).

**Async UI** — use `PumpHelpers.waitFor(tester, finder, reason: '...')` instead of manual pump loops. Use `PumpHelpers.pumpFrames` when `pumpAndSettle` would hang due to background streams.

**Semantics** — use `PumpHelpers.findBySemanticsId(identifier)` to find widgets by their `Semantics.identifier` without needing the full semantics tree.
