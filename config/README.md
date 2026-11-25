# Local build config

`turn.dev.json` is git-ignored and passed with `--dart-define-from-file` to the chat app and the `webrtc_call` example. Create it from `turn.dev.example.json`:

| Key | Meaning |
|---|---|
| `TURN_DEV_SECRET` | coturn `static-auth-secret`; the app mints short-lived TURN credentials from it. Dev builds only — anyone can extract it from the build (doc/webrtc-assumptions.md, #3). Without it calls use STUN only. |
| `CALL_RELAY_ONLY` | `true` restricts ICE to TURN relay candidates, to check that TURN works. |

Run: the "… (TURN)" configurations in `.vscode/launch.json`, or `fvm flutter run --dart-define-from-file=../../config/turn.dev.json` from `packages/chat` (`../../../config/…` from the example).
