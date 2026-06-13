# packages/chat — Nostr Chat App

> ⚠️ **Draft.** This package is in early draft state. Whether it will be developed further is unknown. Do not depend on its API or structure being stable.

Nostr-based encrypted chat application. Separate entry point from `packages/notes`.

---

## Differences from `packages/notes`

| Aspect | notes | chat |
|--------|-------|------|
| DI | `di_storage` | `get_it` |
| Routing | `go_router` | `auto_route` |
| State | `flutter_bloc` + `Vm` | `flutter_bloc` |

---

## Structure

```
lib/
  auth/           ← Authenticated features
  common/         ← Shared within chat
  unauth/         ← Onboarding / login
  router/         ← auto_route setup
  main.dart
```

---

## Known issues

- `build/` directory may be picked up by the Dart analyzer (SPM packages from `google_mobile_ads`). The `analysis_options.yaml` excludes `build/**` to suppress this.
- `riverpod_generator` brings in `mockito 5.7.0` which is incompatible with `analyzer ^10.0.0`. A `dependency_overrides` constraint is set in `pubspec.yaml` to pin `mockito` to `<5.6.5`.
