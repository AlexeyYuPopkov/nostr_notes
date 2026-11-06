---
name: feature-layout
description: Where code goes inside an app package — top-level areas (`common`, `unauth`, `auth`), the `data`/`domain`/`presentation` layers inside each, what is shared and at which level, and how `test/` mirrors `lib/`; shared principles plus per-package details (chat splits `auth` into features, notes doesn't). Use when creating a file, screen, provider/bloc, usecase, repo or model in packages/chat, packages/notes or a new app package, moving code between features, areas or into `packages/common`, or deciding where a test or BDD feature lives.
---

# Feature layout

Shared principles for every app package (notes, chat, new ones):

- Split by **access area** first: `unauth` (before sign-in), `auth` (after), `common` (used by both).
- Inside an area, code is split into the **layers** `data` / `domain` / `presentation` — never screens directly under `auth/` or `unauth/`.
- Code lives at the **narrowest level** that covers all of its users and moves up only when a second user appears (see *Where does it go?*).
- `test/` mirrors `lib/`.

Details differ per package — the state folder (`provider/` vs `bloc/`), DI and router folders, whether `auth` is split into features. Each package has its own section below; when they disagree with the shared part, the package section wins. Don't copy one package's details into the other.

## packages/chat

`auth` is split into features, each with its own layers.

### Tree

```
lib/
  main.dart
  router/                 ← AppRouter, @RoutePage wrappers, XScreenCoordinatorImpl (see `navigation-coordinator`)
  l10n/
  common/                 ← used by BOTH auth and unauth
    di/                   ← `Di` (get_it scopes)
    debug/                ← Marionette config, debug-only tooling
    data/
    domain/
    presentation/
  unauth/                 ← before sign-in (onboarding)
    data/
    domain/
    presentation/
      onboarding/
  auth/                   ← after sign-in, one folder per feature
    common/               ← shared by several auth features, never by unauth
      data/ domain/ presentation/
    home/                 ← tab-bar shell (`HomeNavigationBar`; the `AuthTabsPage` route wrapper stays in router/)
      presentation/home/
    chat/                 ← chats list, chat, contact search
      data/
      domain/
      presentation/
        chats_list/
        chat/
        search_contact/
    settings/
      data/
      domain/
      presentation/
```

A layer folder that would be empty is not created: `home/` has only `presentation/` until it needs more.

A new auth feature gets its own folder when it has a screen of its own and its own domain (models/usecases). A screen that only shows another feature's data stays inside that feature.

Chat specifics: state in `provider/` (Riverpod notifier + `*_state.dart`/`*_data.dart`), DI in `common/di/`, routing in top-level `router/`. Scenarios that start from the tab shell (`I open the authorized area`) share steps, so they live together in `test/auth/bdd/`.

## packages/notes

```
lib/
  main.dart
  app/            ← app shell: di/ (auth/, unauth/ modules), router/ (AppRouter, *_router_part.dart, screens_assembly/), app-wide widgets
  common/         ← used by auth and unauth: data/, domain/, presentation/
  unauth/         ← data/, domain/, presentation/<screen>/
  auth/           ← data/, domain/, presentation/<screen>/ (dashboard, note_screen, settings/…)
  services/       ← platform services with no screen: crypto FFI, nip44, app workers, backup files
  core/           ← NostrKind constants, low-level tools
  ffigen/         ← generated FFI bindings
  l10n/
```

Notes specifics:
- `auth` is **not** split into features (yet): layers are directly under `auth/`, screens under `auth/presentation/<screen>/`. Add new code into this layout; splitting notes into features is a separate decision, not done in passing.
- Settings screens nest under `auth/presentation/settings/<screen>/` and are reached through `DrawerRouter`.
- State in `bloc/` next to the screen (or a `Vm` for lightweight state). Domain subfolders are `model/`, `repo/`, `usecase/`.
- Code with no UI and no Nostr domain meaning (FFI, file IO, background workers) goes to `services/`, not to `data/`.

## Layers (both packages)

| Layer | Contains | May import |
|---|---|---|
| `domain/` | models (`models/` in chat, `model/` in notes), `repo/` (interfaces), `usecase/` (interfaces + params) | `domain` of the same or a wider level, `packages/common` domain, `nostr` models |
| `data/` | repo/usecase implementations, mappers, DTOs (`model/`), helpers for one data source grouped in a subfolder (`search_contacts/`) | its own `domain`, wider-level `data`/`domain`, `nostr`, `packages/common` |
| `presentation/` | one folder per screen: `<screen>_screen.dart`, state folder (`provider/` in chat, `bloc/` in notes), `widgets/` | `domain` only — never `data` (implementations come through DI) |

- `presentation` → `data` imports are forbidden; the screen gets usecases/repos from DI (`get_it` in chat, `DiStorage` in notes).
- A modal or sub-page that belongs to one screen nests inside that screen's folder (`onboarding/pages/relays/`).
- Navigation targets are not imported across features; transitions go through the screen's coordinator.

## Where does it go?

Pick the first level that covers **every** current user:

1. One screen → that screen's folder.
2. One area (or, in chat, one feature) → `auth/<layer>/` / `auth/<feature>/<layer>/` / `unauth/<layer>/`.
3. Several chat auth features → `auth/common/<layer>/`.
4. Both auth and unauth (session, auth usecase) → `common/<layer>/`.
5. Both apps (notes and chat) → `packages/common` (domain models such as `User`, `RawEventStore`, theme, shared widgets). Pure protocol code → `packages/nostr`.

When code gains a user outside its current level, move it up in the same change. When its last outside user goes away, move it down. Don't put code in `common` "in case" it's needed later. Moving code into `packages/common` means it fits both apps — app-specific details (Bloc vs Riverpod, DI container, routes) stay in the app.

## Tests

`test/` mirrors `lib/`: the test for `lib/auth/chat/data/x.dart` is `test/auth/chat/data/x_test.dart`.

- BDD files go in a `bdd/` folder with steps in `bdd/steps/`, at the narrowest test level whose features share those steps (`test/auth/<feature>/bdd/` if only one feature uses them, `test/auth/bdd/` if several auth features do). Steps in one test folder can't be found from another — the generator only looks in `./steps` and `externalSteps`.
- Steps reused by features in different folders go to a test kit (`app_test_kit` app-agnostic, `notes_test_kit` notes-only) and `externalSteps` in `build.yaml` — see CLAUDE.md *Testing*.
- Test tooling (`AppLauncher`, fakes for relays) stays in `test/tools/`.

## Migrating current code

chat follows this layout. In notes, `test/onboarding/` predates the mirror rule — leave it unless you touch it, then move it to `test/unauth/presentation/onboarding/`.

After moving files, run `make codegen` (Riverpod `.g.dart`, `auto_route` `.gr.dart`), fix relative imports in moved tests, and run the analyzer and tests.
