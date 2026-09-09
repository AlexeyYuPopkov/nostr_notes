# Project Conventions & AI Agent Guidelines

## 1. Code Style & Standards
- **Strict Const**: Always use `const` for widget constructors, literals, and declarations where possible. This is enforced by `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, and `prefer_const_declarations` in `analysis_options.yaml`.
- **Trailing Commas**: Mandatory for all function arguments, constructor parameters, and collection literals to maintain clean diffs and consistent formatting (`require_trailing_commas: true`).
- **Typing**: Avoid `dynamic` and raw `Map<String, dynamic>` where possible. Prefer creating models or using extensions for parsing (e.g., `ZapRequestDescription`, `ZapConfirmationSum`).
- **Self-documenting code**: The default is no comment. Carry meaning in intention-revealing names, named constants instead of magic numbers, a named local for a complex condition, an extracted function instead of a header comment, and types that make invalid states unrepresentable. Needing a comment to make a block readable is a signal to extract and name it. See [.agents/skills/self-documenting-code/SKILL.md](.agents/skills/self-documenting-code/SKILL.md).
- **Comments**: Reserve them for what the code cannot hold — *why* rather than what, an external quirk or upstream bug (with a concrete reference), or non-obvious lifecycle/async semantics. Keep them to one line where possible. Never commit commented-out code, comments that paraphrase the line below, or changelog/attribution notes.

## 2. Nostr Architecture
- **Event Kinds**: Use `NostrKind` constants instead of magic numbers for event types.
- **Service Tags**: For NIP-57 Zaps, always include the `client` tag (e.g., `AppConfig.clientTagValue` or `AppConfig.appId`).
- **Keys Management**: Handle user keys through `SessionUsecase` and `UserKeys` model. Never pass private keys as plain strings in UI layers.

## 3. Testing Patterns
- **Widget Tests**: Use `AppLauncher.launchApp` to wrap widgets with necessary providers (DI, Localization, Theme).
- **DI in Tests**: Use `DiStorage.shared` for dependency injection for `packages/notes` and `get_it` for `packages/chat`. Always clean up in `tearDown` using `DiStorage.shared.removeAll()`.
- **Mocking**: Use `Mocktail` for mocking dependencies.
- **Wait Helpers**: Use `PumpHelpers.waitFor` for asynchronous UI updates instead of manual `tester.pump` loops with magic durations.

## 4. Architecture (Clean Architecture Lite)
- **UI**: Flutter widgets and ViewModels (`Vm`).
- **Domain/Data**: 
  - `Usecase` for business logic (e.g., `FetchLightningDonationUsecase`).
  - `Repository` for data abstraction.
  - Implementations live in the `data` layer or package-specific folders.
- **DI**: Managed via `di_storage` package for `packages/notes` and `get_it` package for `packages/chat`.

## 5. Mono-repo Structure (Melos)
- **packages/common**: Shared business logic, models, and low-level services.
- **packages/notes**: Main application logic, UI, and feature-specific code for the notes app.
- **packages/chat**: Main application logic, UI, and feature-specific code for the chat app.
- **packages/nostr**: Pure Nostr protocol implementation and clients.
- **cpp/**: Native modules for cryptography (secp256k1) and performance.

## 6. AI Agent Guidelines
- **Context**: When asking an agent to work on Zaps, mention NIP-57.
- **Docs**: Prefer a name that needs no explanation over a docstring. Add `///` only where the public contract isn't already in the signature — units, side effects, ordering, what `null`/empty means, what the caller must dispose. Do not document every public member reflexively.
- **Comment budget**: Agents tend to over-comment. Before leaving a comment, apply the checklist in [.agents/skills/self-documenting-code/SKILL.md](.agents/skills/self-documenting-code/SKILL.md); a rename, constant, or extracted function usually removes the need for it.
- **Validation**: After any code change involving UI or logic, check for `const` warnings and run relevant tests using `runTests`.

## 7. Flutter AI Agent Skills
Skills live in `.agents/skills/`. The `flutter-*` ones are generated from [official Flutter AI Agent Skills](https://docs.flutter.dev/ai/agent-skills) — identifiable by the `metadata.model` / `last_modified` frontmatter — so don't hand-edit them; a re-sync overwrites the changes. Project-owned skills (`nostr`, `self-documenting-code`) have no such frontmatter and are the place for local rules. Where the two disagree, this file and the project-owned skills win.

When working as an AI agent, apply the following principles:
- **Widget Testing**: Adhere to the `flutter_test` guidelines. Prefer `findsOneWidget` and semantic-based finders. Use `const` for test widgets where possible.
- **Performance**: Minimize unnecessary rebuilds. Use `const` constructors and prefer `ValueListenableBuilder` or specific BLoC/State updates over `setState` at the root.
- **Accessibility**: Ensure widgets include proper `Semantics`.
- **Dart Best Practices**: Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines for style, documentation, and usage.
- **Assets**: Follow the standard Flutter asset management patterns, ensuring assets are correctly declared in the package-specific `pubspec.yaml`.

## 8. Nostr Protocol Skill
This project uses the [Nostr Protocol Skill](.agents/skills/nostr/SKILL.md). When working as an AI agent:
- Follow NIP-01 for basic event structures and relay communication.
- Use NIP-57 for Zap-related logic, ensuring proper tagging of `p`, `P`, and `description`.
- Always prioritize cryptographic safety and proper signature verification.

## 9. Routing
- for `packages/notes` use `go_router` package. Dont use GoRouter.of(context) right from ui. Use `RouteHandler` to keep routing logic closer to routes configuration `packages/notes/lib/app/router/app_router.dart`. (According Information expert pattern)
- for `packages/chat` use `auto_route` package 