# webrtc_call example

A video call between two devices through `package:webrtc_call`, without the chat app.

1. Run it on two devices: **WebRTC call example (debug)** in `.vscode/launch.json`, or `fvm flutter run`. The iOS simulator has no camera.
2. Press **Connect** on both. Each gets a random id; an id must not contain `-`.
3. Tap the other device in the list. The call is answered automatically for now.

Signaling defaults to `wss://alekseiiapi.site:8086/ws`; override with `--dart-define=SIGNALING_URL=...`.
Only STUN is configured, so calls between networks behind CGNAT (LTE) may not connect until TURN is added.
