# Local build config

`turn.dev.json` is git-ignored and passed with `--dart-define-from-file` to the chat app and the `webrtc_call` example. Create it from `turn.dev.example.json`. Call servers and flags otherwise come from Firebase Remote Config (doc/firebase-plan.md); the keys below are the local overrides and the values that must not go there.

| Key | Meaning |
|---|---|
| `TURN_DEV_SECRET` | coturn `static-auth-secret`; the app mints short-lived TURN credentials from it. Dev builds only — anyone can extract it from the build (doc/webrtc-assumptions.md, #3). Without it calls use STUN only. |
| `CALL_RELAY_ONLY` | `true` restricts ICE to TURN relay candidates, to check that TURN works. In the chat it wins over Remote Config `call_relay_only`. |
| `SIGNALING_URL` | Optional. Signaling WebSocket URL; in the chat it wins over Remote Config `signaling_url` (doc/firebase-plan.md). |
| `TURN_TTL_SECONDS` | Optional, default `3600`. Lifetime of the minted TURN credentials; the caller restarts ICE with fresh ones after 5/6 of it. Set e.g. `120` to check the refresh without a one-hour call. |

Run: the "… (TURN)" configurations in `.vscode/launch.json`, or `fvm flutter run --dart-define-from-file=../../config/turn.dev.json` from `packages/chat` (`../../../config/…` from the example).
