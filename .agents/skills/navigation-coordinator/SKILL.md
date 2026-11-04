---
name: navigation-coordinator
description: Project navigation pattern — screens never decide where to go; they call an injected `XScreenCoordinator`, and `XCoordinatorImpl` next to the route configuration performs the transition (go_router in packages/notes, auto_route in packages/chat). Use when adding a screen, a route or a transition, editing `AppRouter`/`NoteRouter`/`*_router_part.dart`/`DrawerRouter`/`ScreensAssembly` or `chat/lib/router/`, or when a widget is about to call `GoRouter.of`, `context.go/push`, `context.router`, `AutoRouter.of` or `context.replaceRoute`.
---

# Navigation: transitions live outside screens

Background: https://dev.to/alexeyyupopkov/flutter-navigation-moving-transitions-out-of-screens-l1a

**Principle (Information Expert).** A screen doesn't know which stack, pane or tab it's in, so it can't know whether "open X" means push, replace or switch tab. It reports the intent through a contract; the code that builds the screen has that context and performs the transition. The same screen can be reused in another place with another implementation.

## The pieces

| Piece | Where | What |
|---|---|---|
| `abstract interface class XScreenCoordinator` | Same file as the screen | One method per intent: `onNotePreviewRoute(context, noteId: …)`, `onCreateNoteRoute(context)`. Pass data the transition needs, nothing router-specific. |
| `final class XScreenCoordinatorImpl implements XScreenCoordinator` | Next to the route config — notes: `app/router/*_router_part.dart` (`part of` the router) | Calls the router. Usually `const`; takes `GlobalKey`s etc. via constructor when it needs them (`HomeScreenCoordinatorImpl`). |
| Screen | `presentation/…` | `final XScreenCoordinator coordinator;` constructor param; calls `coordinator.onXRoute(context, …)` from UI callbacks or bloc listeners. |
| Assembly | notes: `ScreensAssembly` / `AppScreensAssembly`; chat: the `@RoutePage` wrapper | Builds the screen and injects the implementation. |

Transitions reused by several implementations go into a mixin next to the routes (`NewNoteRoute`, `NewLoginItemRoute` in `app/router/create_routes.dart`); implementations mix them in.

## Coordinator vs `RouteHandler` / `AppRoute` (notes)

- **Coordinator** — the default for every screen reached through go_router (`AppRouter`, `NoteRouter`).
- **`RouteHandler` + `AppRoute`** — only inside the settings drawer (`DrawerRouter`), which runs its own nested `Navigator`. A screen emits a route object (`RouteHandler.of(context)?.onRoute(const PreferencesRoute(), context)`, routes in `settings_screen_routes.dart`); each `RouteHandlerWidget.onRoute` handles what it can and forwards the rest upward with `RouteHandler.of(context)?.onRoute(route, context)`. Use it only for new settings screens; don't introduce it elsewhere.

## Recipe: new screen / transition in packages/notes (go_router)

1. In the screen file declare `XScreenCoordinator` with the intents; add `required this.coordinator` to the screen; call it from the UI.
2. Add the path to `AppRouterPath`.
3. Add a factory to `ScreensAssembly` taking `required XScreenCoordinator coordinator`, implement it in `AppScreensAssembly`.
4. Register a `GoRoute` in `AppRouter` (or a feature router like `NoteRouter`) whose builder calls the assembly with the implementation.
5. Write `XScreenCoordinatorImpl` in the router's `*_router_part.dart`:
   - detail pane (list → details on wide layouts): `GoRouter.of(context).openInPane(path, extra: …)` — pushes into an empty pane, replaces otherwise;
   - plain stack: `push`; another branch/shell: `go`.
6. Arguments travel as `extra: Params(...).toJson()` and are restored with `Params.fromJson(state.extra as Map<String, dynamic>)` in the builder. That `Map<String, dynamic>` is a known go_router compromise — keep it inside the router, never let it reach a screen.

## Recipe: new screen / transition in packages/chat (auto_route)

1. Screen file: declare `XScreenCoordinator`, take it in the constructor, call it. The screen itself is **not** `@RoutePage()`.
2. In `lib/router/` add a page wrapper that binds the screen to its implementation, plus the implementation:
   ```dart
   @RoutePage()
   final class OnboardingPage extends StatelessWidget {
     const OnboardingPage({super.key});

     @override
     Widget build(BuildContext context) =>
         const OnboardingScreen(coordinator: OnboardingScreenCoordinatorImpl());
   }

   final class OnboardingScreenCoordinatorImpl implements OnboardingScreenCoordinator {
     const OnboardingScreenCoordinatorImpl();

     @override
     void onSignedIn(BuildContext context) => context.router.replace(const HomeRoute());
   }
   ```
3. Register `AutoRoute(page: OnboardingRoute.page)` in `AppRouter.routes`, run `make codegen`.
4. Transitions: `context.router.push/replace`; leaving a nested router for a sibling tab: `context.router.root.navigatePath(...)`.

## Allowed in screens without a coordinator

Deliberate trade-offs against boilerplate. Both use plain Flutter APIs, so the screen still doesn't depend on go_router or auto_route:
- **Closing itself** — `Navigator.of(context).pop(result)`, e.g. after save/delete (`LoginItemFormScreen`), a dialog's Cancel/OK.
- **Modal dialogs and sheets** — `showDialog`, `showAdaptiveDialog`, `showModalBottomSheet`, `showCupertinoModalPopup` and the like, built and awaited right in the screen (e.g. `ExportPasswordDialog`, `AccountsImportDialog`). The dialog returns its result to the screen.

Anything that *opens* or *replaces* a destination (a screen/page) goes through the coordinator — including a navigation triggered by a dialog's result.

## Tests

Don't write tests whose only assertion is "coordinator method X was called" — that's a one-line delegation, the risk is negligible. The coordinator's value for tests is that a screen can be pumped in a widget/BDD test without a configured router: pass a no-op implementation (see `_TestNotesListCoordinator` in `packages/notes/test/auth/presentation/notes_list/notes_list_test.dart`).

## Don't

- Call `GoRouter.of`, `context.go/push`, `context.router`, `AutoRouter.of`, `context.pushRoute/replaceRoute` from a screen or a bloc.
- Pass a router, `GoRouterState` or a route class into a screen.
- Build the next screen inside the current one (`Navigator.push(MaterialPageRoute(builder: (_) => NextScreen()))` in a screen). Modal dialogs/sheets are the exception — see above.
- Put the implementation in the screen's file — it belongs to the place that builds the screen.
