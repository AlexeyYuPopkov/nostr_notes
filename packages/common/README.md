# packages/common — Shared Package

Shared UI components, theme, database, and localization utilities. No app entry point — consumed by `packages/notes` and `packages/chat`.

---

## Contents

```
lib/
  app/
    theme/        ← AppTheme, AppBackgroundColors, color schemes
  data/           ← Repository implementations (theme, settings)
  domain/         ← Repository interfaces, GlobalSettingsScope/GlobalSettingsVm
  l10n/           ← CommonLocalizations (en, ru, bg); localization.dart helper
  presentation/
    buttons/      ← Reusable button widgets
    dialogs/      ← AppAlertDialog, DialogHelper mixin, dialog buttons
    widgets/      ← SettingsItemTile, OnboardingTextField, ProgressHud, MarkdownWidget, …
  tools/          ← OptionalBox and other utilities
```

**Database** — `AppDatabase` (drift/SQLite). Shared schema across apps.

**Theme** — `AppTheme` with light/dark variants. Background colors managed via `AppBackgroundColors`. Users configure theme mode and color scheme via `GlobalSettingsVm`.

**Localization** — `CommonLocalizations` delegate supports `en`, `ru`, `bg`. Use `context.commonL10n` (extension in `localization.dart`).

---

## Localization

ARB files in `lib/l10n/`. After editing, regenerate from repo root:

```bash
make l10n
```

---

## Tests

```bash
cd packages/common && fvm flutter test
```

Test utilities in `test/tools/di/` are re-exported for use in other packages (e.g., `InMemoryDbModule`).
