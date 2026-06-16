# packages/notes — Private Notes App

Main Flutter application. Entry point: `lib/main.dart`.

**Platforms:** iOS · Android · macOS · Web

---

## Architecture

Clean Architecture layers inside `lib/`:

```
app/              ← DI setup (Di/AppDi), go_router config, AppConfig
auth/
  domain/         ← Models (Note, Label), Usecase/Repository interfaces
  data/           ← Usecase/Repository implementations, mappers
  presentation/   ← Screens, Blocs, Vm (ViewModels)
common/           ← Cross-feature shared domain/presentation within the app
services/         ← CryptoService (FFI), OutboxPublisher, background workers
core/             ← NostrKind constants, low-level tools
unauth/           ← Pre-login screens (onboarding)
```

**State management**
- `flutter_bloc` (`Bloc`) for screen-level state. State classes carry a `data` field; sealed subclasses represent transitions (`LoadingState`, `ErrorState`, `CommonState`).
- Custom `Vm extends ValueNotifier` for lightweight reactive state (e.g., `PendingVm`).

**DI** — `di_storage` (`DiStorage.shared`), not `get_it`.
- `Di.instance.bindUnauthModules()` — called at startup.
- `Di.instance.bindAuthModules()` — called when session is authenticated.
- Scopes are removed on logout.

**Routing** — `go_router`. Never call `GoRouter.of(context)` from UI; use `RouteHandler.of(context)?.onRoute(SomeRoute(), context)` instead.

**Nostr specifics**
- Event kinds via `NostrKind` constants. Notes are kind `30023` (NIP-33).
- Zaps follow NIP-57: always include `p`, `P`, `description` and `client` tags.
- `OutboxPublisher` handles async relay publishing with outbox queue persistence.

---

## Running & building

```bash
# Get dependencies (from repo root)
make bootstrap

# Run (from this directory)
fvm flutter run

# Build release APK
make build_apk          # from repo root

# Build native FFI (required if crypto module is missing)
make ffi-ios            # iOS xcframework
make ffi-macos          # macOS xcframework
```

---

## Tests

### Unit & widget tests

```bash
# All tests
cd packages/notes && fvm flutter test

# Single file
cd packages/notes && fvm flutter test test/auth/domain/create_note_usecase_test.dart

# With coverage (from repo root)
make test
```

**Widget tests** — wrap in `AppLauncher.launchApp(child: ..., tester: ...)` (see `test/tools/app_launcher/`) to get theme, l10n, and `RootContextProvider`.

**DI in tests** — bind via `DiStorage.shared`; always clean up:
```dart
tearDown(() => DiStorage.shared.removeAll());
```

**Async UI** — use `PumpHelpers.waitFor(tester, finder)` instead of manual pump loops. Use `PumpHelpers.pumpFrames` when `pumpAndSettle` would hang due to background streams.

**Mocking** — `Mocktail`. In-memory DB via `InMemoryDbModule` (re-exported from `packages/common/test/tools/di/`).

### Integration tests

> ⚠️ Integration tests in `integration_test/` have degraded over time and are unlikely to run out of the box. They also require a local Nostr relay running in Docker:
> ```bash
> make relay_up   # starts relay via Fastlane + Docker
> ```
> Running them via Fastlane: `bundle exec fastlane integration_test test:registration_test.dart`

---

## Localization

Supported locales: **English**, **Russian**, **Bulgarian**.

ARB files in `lib/l10n/`. After editing, regenerate:
```bash
make l10n   # from repo root
```

---

## Clean cache

```bash
flutter clean && flutter pub get
# or if dart_tool issues:
rm -rf .dart_tool/hooks_runner && flutter pub get
```
