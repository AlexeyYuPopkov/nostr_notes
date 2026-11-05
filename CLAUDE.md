# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

**Flutter version**: pinned in `.fvmrc` (currently 3.47.7), managed via FVM — use `fvm flutter`. CI reads the same file (`flutter-version-file: .fvmrc`).

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
- **`packages/chat`** — Chat app (iOS only). Uses `get_it` for DI, `auto_route` for routing, Riverpod for state — see *Architecture (packages/chat)*.
- **`packages/nostr`** — Pure Nostr protocol: `NostrClient`, `NostrRelay`, event models, NIP implementations.
- **`packages/common`** — Shared models (incl. `User` kind 0 profile + `UserMapper`, `AccountAvatar`), theme (`AppTheme`, `AppBackgroundColors`), `GlobalSettingsScope`/`GlobalSettingsVm`, presentation widgets, `AppDatabase` (drift/sqlite).
- **`packages/app_test_kit`** — Test-only, app-agnostic (dev dependency of `notes` and `chat`): `PumpHelpers`, `visibleText` finder, generic BDD steps (`I see/tap text`, semantics, clipboard, text fields). Must not depend on either app.
- **`packages/notes_test_kit`** — Test-only, notes-specific (dev dependency of `notes`; depends on the notes app): `TestAppDiOverridesProxy`, backup-file fakes, notes BDD steps (`a_fresh_install`, key-file/backup steps).
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
- Uses `go_router`. Screens never call the router: they call an injected `XScreenCoordinator`; `XScreenCoordinatorImpl` lives in `app/router/*_router_part.dart` and is injected via `ScreensAssembly`. `Navigator.of(context).pop()` and modal dialogs/sheets (`showDialog`, `showModalBottomSheet`, …) straight from a screen are allowed.
- Inside the settings drawer (`DrawerRouter`, nested `Navigator`) screens emit `AppRoute` objects via `RouteHandler.of(context)?.onRoute(SomeRoute(), context)` (routes in `settings_screen_routes.dart`).
- `AppRouter` manages the `GoRouter` instance, handles auth redirect, and refreshes on session changes.
- Recipes and rules: the `navigation-coordinator` skill.

**State management**:
- `flutter_bloc` (`Bloc`) for screen-level state (settings, credentials, donate flows).
- Bloc state classes carry a `data` field (a dedicated data class) holding the screen's content. Sealed subclasses represent transient states (`LoadingState`, `ErrorState`, `CommonState`, etc.).
- Custom `Vm extends ValueNotifier` for lightweight reactive state (e.g., `PendingVm`).

**Nostr specifics**:
- Event kinds: use `NostrKind` constants (not magic numbers). Notes are kind `30023` (NIP-33 Parameterized Replaceable Events).
- Zaps follow NIP-57: always include `p`, `P`, `description` tags and the `client` tag (`AppConfig.clientTagValue`).
- `OutboxPublisher` handles async relay publishing with outbox queue persistence.
- Keys managed through `SessionUsecase` / `UserKeys`. Never pass private keys as plain strings through UI layers.
- Full protocol rules (kinds table, tags, relays, NIP-44): the `nostr` skill.

## Architecture (packages/chat)

Don't carry notes patterns (Bloc, `Vm`, `DiStorage`, `go_router`) into chat.

```
lib/
  common/       ← used by auth and unauth: di/ (`Di`, get_it scopes), debug/ (Marionette), domain/ (Session, AuthUsecase, SessionUsecase)
  router/       ← `AppRouter` (@AutoRouterConfig); `auth_router.dart` — @RoutePage wrappers, coordinator impls
  unauth/presentation/onboarding/
  auth/
    home/       ← tab-bar shell (`HomeNavigationBar`)
    chat/       ← domain/ (Chat, ChatsRepo, search usecases), data/ (`FakeChatsRepo` — in-memory; search_contacts/ — offline-first kind 0 search: `SearchContactsFetchUsecaseImpl` fills `RawEventStore` from relays, `SearchContactsGetUsecaseImpl` watches it), presentation/ (chats_list, chat, search_contact — modal)
    settings/presentation/settings/
```

Where new code goes (features, layers, shared levels, tests): the `feature-layout` skill.

- **DI**: `get_it`. `Di.registerUnauthModules()` pushes the `unauth-scope`; drop it with `Di.dropUnauthModules()`. `Di.registerAuthModules()` pushes the `auth-scope` (chat repos) when onboarding completes. Shared repos/usecases come from `packages/common`.
- **State**: Riverpod 3 with codegen — `@riverpod` notifiers in a `provider/` folder next to the screen, UI as `ConsumerWidget`. Root is `ProviderScope` in `main.dart`. Run `make codegen` after changing a provider.
- **Routing**: `auto_route`, routes registered in `router/app_router.dart`. Same coordinator pattern as notes: the screen takes an `XScreenCoordinator`; a `@RoutePage()` wrapper in `router/` builds it with `XScreenCoordinatorImpl`. See the `navigation-coordinator` skill. (`OnboardingScreen` still calls `context.replaceRoute` directly — not yet migrated.)
- **Tests**: wrap in `AppLauncher.launchApp` from `packages/chat/test/tools/app_launcher/` (gives `ProviderScope`, theme, l10n). Call `AppLauncher.setUp()` in `setUp` and `addTearDown(AppLauncher.tearDown)`; it swaps `SecureStorage` for a fake in `get_it`. BDD steps shared with notes come from `app_test_kit` (listed in `packages/chat/build.yaml`); never add `notes_test_kit` to chat — it pulls in the notes app and its native plugins.

## Running the app with an AI agent (Marionette)

The chat app starts `MarionetteBinding` in debug builds (`kDebugMode`), so an agent can tap, type, scroll and screenshot the running app through the `marionette` MCP server (`.mcp.json`).
1. Run **Chat (debug)** from `.vscode/launch.json`, or `cd packages/chat && fvm flutter run`.
2. Take the VM Service URI from the console (`http://127.0.0.1:PORT/TOKEN=/`) and give the agent `ws://127.0.0.1:PORT/TOKEN=/ws` to `connect`.
3. Custom widgets Marionette must see go into `packages/chat/lib/common/debug/marionette_config.dart` (it doesn't detect `CupertinoButton` on its own).

The `marionette_flutter` version in `packages/chat/pubspec.yaml` must match the globally activated `marionette_mcp` (`dart pub global activate marionette_mcp`). How to drive the app: the `marionette-flutter-drive-app` skill.

## AI agent setup

- Instructions: this file. `AGENTS.md` is a symlink to it; `.github/copilot-instructions.md` points here.
- Skills: `.agents/skills/` (`.claude/skills` is a symlink to it). Project-owned skills are `nostr`, `navigation-coordinator`, `offline-first`, `feature-layout` and `self-documenting-code`. The `flutter-*` and `marionette-*` skills are copied from upstream, so re-sync them instead of hand-editing them. Where a skill and this file disagree, this file wins.
- MCP servers: `.mcp.json` — `dart` (analyzer, tests, pub) and `marionette` (drive the running app).
- Claude Code: shared settings and the `reference_prompt.sh` hook live in `.claude/settings.json`; personal permissions go in the git-ignored `.claude/settings.local.json`.

## Code Style

- **`const`** everywhere possible — enforced by linter (`prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `prefer_const_declarations`).
- **Trailing commas** required on all multi-line argument lists and collection literals (`require_trailing_commas: true`).
- **Single quotes** for strings.
- **No `dynamic`** — create typed models or extensions instead of raw `Map<String, dynamic>`.
- Always declare return types (`always_declare_return_types`).
- Interactive widgets get `Semantics` (with an `identifier` where tests or Marionette need to target them).
- After a change, run the analyzer and the relevant tests (Dart MCP `analyze_files` / `run_tests`, or `fvm flutter analyze` / `fvm flutter test`).

### Comments and naming

Default to **no comment**. Say it in the code instead: intention-revealing names, named constants over magic numbers, a well-named local or getter for a complex condition, small functions whose name states what they do, types that make invalid states unrepresentable. If a block needs a comment to be readable, that is usually a signal to extract and name it.

Add a comment only for what the code cannot carry:
- **Why**, never what — a non-obvious tradeoff, ordering requirement, or constraint.
- An external quirk or upstream bug, with a concrete reference (package + version, file:line, or issue link).
- `///` on public API only where the contract isn't already in the signature: units, side effects, ordering, what `null`/empty means. Don't restate the name.

Never:
- A comment that paraphrases the line under it.
- Commented-out code — delete it, git has the history.
- Changelog or attribution notes (`// added ...`, `// fixed ...`) — that's what commits are for.

Keep a needed comment to the shortest form that carries the point, usually one line. Full guidance and before/after examples: [.agents/skills/self-documenting-code/SKILL.md](.agents/skills/self-documenting-code/SKILL.md).

## Testing

**Which kind of test** (both `notes` and `chat`):
- **BDD** (`*.feature`) for any new test of a user-visible scenario that crosses layers — screen + state + usecase/repo — with external dependencies (relays, network, secure storage, file dialogs, clipboard) faked or mocked. If it reads naturally as Given/When/Then, write it as a feature.
- **Plain `test`/`testWidgets`** for unit tests: one class, function, mapper, DTO or usecase in isolation.
- Existing plain tests aren't converted just for the sake of it.

**BDD mechanics** (`bdd_widget_test`, `*.feature` → generated `*_test.dart`; run `make codegen` or `fvm dart run build_runner build` in the package, then `fvm dart format` the generated files):
- A feature's own steps live in `steps/` next to it.
- A step used by features in different folders must be importable via `package:`, so it lives in a test kit and is listed under `externalSteps` in the package's `build.yaml` — otherwise the generator creates a new stub. App-agnostic steps go to `app_test_kit` (and both `build.yaml` files), notes-specific ones to `notes_test_kit`.

Chat-specific test setup: see *Architecture (packages/chat)*.

### packages/notes

**Widget tests** — wrap in `AppLauncher.launchApp(child: ..., tester: ...)` (see `test/tools/app_launcher/app_launcher.dart`) to get theme, localization, and `RootContextProvider`.

**DI in tests** — bind via `DiStorage.shared`; always clean up in `tearDown`:
```dart
tearDown(() => DiStorage.shared.removeAll());
```

**Mocking** — use `Mocktail`. In-memory DB available via `InMemoryDbModule` (re-exported from `packages/common/test/tools/di/`).

**Async UI** — use `PumpHelpers.waitFor(tester, finder, reason: '...')` instead of manual pump loops. Use `PumpHelpers.pumpFrames` when `pumpAndSettle` would hang due to background streams.

**Semantics** — use `PumpHelpers.findBySemanticsId(identifier)` to find widgets by their `Semantics.identifier` without needing the full semantics tree.
