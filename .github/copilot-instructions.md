# GitHub Copilot Instructions

For all tasks in this repository, please adhere to the project-specific guidelines and the official Flutter AI Agent Skills.

## Project Guidelines
- **Core Conventions**: Read and follow [CONVENTIONS.md](CONVENTIONS.md) for code style, architecture, and testing patterns.
- **Flutter Skills**: Apply the [official Flutter AI Agent Skills](https://docs.flutter.dev/ai/agent-skills) to all Flutter-related code and tests.
- **Nostr Focus**: This is a Nostr-based project. Follow NIP conventions and use the appropriate package-specific logic (`packages/notes`, `packages/chat`, `packages/nostr`).

## Key Principles
1. **Strict Const**: Always use `const` where possible.
2. **Clean Tests**: Use established test helpers and ensure no flakiness.
3. **Typing**: Prefer strong typing over `dynamic`.
