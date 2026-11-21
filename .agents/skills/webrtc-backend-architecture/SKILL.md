---
name: webrtc-backend-architecture
description: Use when the agent writing the Flutter client needs information about the backend architecture: endpoints, ports, coturn/TURN credentials and iceServers, the signaling server, the self-hosted Nostr relay (NIP-50 profile search, required client tag, NIP-42 status), certificates, operations or known issues.
---

# Backend architecture (WebRTC calls + Nostr chat)

The full, authoritative description of the backend lives in one document in this repository:

**`docs/webrtc-backend.md`**

Read it (the whole file, or the relevant section) BEFORE answering a backend question or writing client code that talks to the backend. If the file is not at that path, search the repo for `webrtc-backend.md`; if it is missing, tell the user and ask them to add it instead of guessing.

## Where to look

- Endpoints, ports, what runs where: sections 2-4
- TURN/STUN, credential algorithm, `iceServers`: section 6.1
- Signaling server: section 6.2
- Nostr relay, tag filter, NIP-50 search rules, NIP-42: sections 6.3, 6.5, 6.6, 7
- Client integration (call_invite, SignalingChannel, CallService): section 8
- Operations and known issues: sections 9-10

## Hard facts to keep in mind (details in the document)

- Calls are started from the Nostr chat via a `call_invite` message, but signaling does NOT go over Nostr.
- Every event published to the relay (any kind except 22242) must carry the tag `["client","996e10ba"]`, otherwise it is rejected; for gift wraps (kind 1059) the tag goes on the outer event.
- Profile search: kind 0 with `search` = `"<text>*"`, only when the text has at least 3 characters; shorter queries make the relay return all profiles.
- TURN credentials are `username = "<expiry_unix>:<id>"`, `credential = base64(HMAC-SHA1(secret, username))`. The shared secret must never be put into the client app or committed to the repo.
- The signaling server has no authentication; NIP-42 is not enabled on the relay.

## Rules

- Do not invent endpoints, ports or protocol details that the document marks as not verified; say they must be checked.
- If the real backend differs from the document, tell the user and suggest updating `docs/webrtc-backend.md`.
