# Alekseii Popkov

**Senior Mobile Engineer · Flutter & Dart · Native iOS · Fintech, Real-time & Cryptography**

Sofia, Bulgaria | +359 876 138 328 | alexey.yu.popkov@gmail.com | [LinkedIn](https://www.linkedin.com/in/alekseii-popkov-57007282/) | [GitHub](https://github.com/AlexeyYuPopkov)

*Authorized to work in EU*

---

## Profile

Senior mobile engineer with 10+ years shipping production apps to the App Store and Google Play — the last six in fintech, decentralised and real-time systems. Ten years of native iOS (Swift, Objective-C, UIKit, WebRTC) now paired with deep Flutter and Dart work: Bloc, Drift, FFI and WASM. Comfortable across the full delivery path from architecture and secure data handling to store release and CI/CD, and equally at home in cryptography-adjacent work — end-to-end encryption, secp256k1 (via WASM for web), and offline-first sync. PhD in radiophysics with a numerical-methods background in C/C++.

*Looking for remote opportunities and meaningful projects.*

---

## Experience

### Senior Mobile Engineer | Social Good Fund

**Remote | Jun 2024 – Present**

Decentralised social platform built on the Nostr protocol (Flutter: mobile and web).

- Built the Nostr networking layer, which connects over WebSockets to any number of relays.
- Designed an offline-first sync engine that keeps local data consistent across many relays despite eventual consistency.
- Refactored core features to Clean Architecture, which reduced coupling and made them easier to test.
- Delivered direct chats, group chats and post feeds end to end, from the protocol layer up to the UI.
- Performance optimization: rewrote message encryption in C/C++ and compiled it to WebAssembly for the web version. Decryption now takes milliseconds instead of seconds.

### Senior Mobile Engineer | PELC Consult GmbH

**Remote | Jan 2023 – Jun 2024**

Training and certification apps for the German market — Flutter and native iOS.

- Re-architected **MATS Training Platform** (Flutter, iOS & Android, 10K+ installs on Google Play): moved core features to Clean Architecture and replaced hand-written JSON parsing with code generation.
- Rebuilt the networking layer on Dio + Retrofit, with token refresh handled in an interceptor. This removed a race condition in the old hand-rolled refresh logic.
- Decoupled dependency injection from `BuildContext`, which made the app testable, then added unit, widget and integration tests covering the key user flows.
- Found and fixed performance bottlenecks by adding caching and by moving business logic and heavy computation out of widget build code.
- Built **SBF-Fragen**, a native iOS quiz app, solo from scratch to App Store release, following Clean Architecture.
- Designed **DiStorage**, a lightweight dependency-injection library published for both Dart (pub.dev) and Swift (CocoaPods), and used it in both apps.

**Shipped:** [SBF-Fragen (App Store)](https://apps.apple.com/bg/app/sbf-fragen-bootsf%C3%BChrerschein/id1658976227) · [MATS (App Store)](https://apps.apple.com/bg/app/mats-training-platform/id6443653002) · [MATS (Google Play)](https://play.google.com/store/apps/details?id=coach.mats.android) 10K+ · DiStorage — [Dart](https://pub.dev/packages/di_storage) & [Swift](https://cocoapods.org/pods/DiStorage)


### Senior Mobile Engineer | System Technologies

**Remote | Nov 2020 – Jan 2023**

Retail and business banking apps built in Flutter for iOS and Android, plus several MVPs and internal projects (Flutter and native iOS). Worked as a senior engineer in a large team of senior and mid-level developers.

- Developed features across **MBANK** (retail, 5M+ downloads) and **MBusiness** (corporate banking, 500K+ downloads), both built on Clean Architecture: UI, complex forms with extensive validation and test coverage, and third-party service integrations, including WebView-based handoff flows.
- Implemented real-time features over WebSockets, turning server events into reactive UI updates.
- Followed established mobile security practices with no custom workarounds: secure credential storage, SSL pinning for the REST API, code obfuscation in the CI/CD pipeline, and sign-in with phone-number verification.
- Did code review and cross-review within the team as a regular part of the job.

**Live in stores:** [MBANK (App Store)](https://apps.apple.com/bg/app/mbank-%D0%BC%D0%BE%D0%B1%D0%B8%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9-%D0%B1%D0%B0%D0%BD%D0%BA/id922922121) · [MBANK (Google Play)](https://play.google.com/store/apps/details?id=com.maanavan.mb_kyrgyzstan) 5M+ · [MBusiness (App Store)](https://apps.apple.com/bg/app/mbusiness/id1669393858) · [MBusiness (Google Play)](https://play.google.com/store/apps/details?id=kg.cbk.mbusiness) 500K+

### Earlier Experience · Native iOS, 2013–2020

| Role | Company | Period |
|------|---------|--------|
| iOS Developer | Technorely — white-label telemedicine apps; refactored into CocoaPods modules | Mar – Nov 2020 |
| iOS Developer | Smart Gamma — iOS applications across several product domains | Sep 2019 – Mar 2020 |
| iOS Developer | River-Soft — three years of iOS feature development and maintenance | Jun 2016 – Sep 2019 |
| Junior iOS Developer | NIX Solutions — started iOS career; feature work and fundamentals | Sep 2013 – Jun 2016 |

---

## Personal Projects

### Private Notes (Nostr) | iOS, macOS, Android & Web — published

Encrypted notes and password manager with decentralised sync, built solo in Flutter
and shipped to the App Store (iOS and macOS), Google Play and the web. Everything is
end-to-end encrypted on the device and stored on relays the user picks, so no server
holds plaintext and there is no sign-up. Wrote the Nostr protocol client from scratch,
an offline-first Drift/SQLite store, secp256k1 through a custom FFI module with a
WASM build for web, and an optional PIN as a second factor.

**Shipped:** [App Store](https://apps.apple.com/bg/app/private-notes-nostr/id6757975921) · [Google Play](https://play.google.com/store/apps/details?id=com.alekseii.yu.popkov.nostrNotes) · [Web](https://alexeyyupopkov.github.io) · [Source](https://github.com/AlexeyYuPopkov/nostr_notes)

---

## Technical Skills

- **Flutter & Dart:** Bloc · RxDart · GoRouter · AutoRoute · Drift (SQLite) · Hive · FFI · WASM · Melos monorepos · code generation
- **Native iOS:** Swift · Objective-C · UIKit · Combine · RxSwift · WebRTC · CoreData · Realm · SwiftPM · CocoaPods
- **Architecture & Testing:** Clean Architecture · SOLID · dependency injection · modularisation · unit, widget and integration tests · TDD
- **Networking & Sync:** REST · WebSockets · Dio/Retrofit · real-time sync · offline-first · Nostr relays
- **Security & Crypto:** end-to-end encryption · secp256k1 · PBKDF2 key derivation · SSL pinning · secure credential storage · code obfuscation
- **Low-level & Delivery:** C/C++ (numerical methods, WASM builds) · CI/CD with GitHub Actions and Fastlane · Firebase · App Store and Google Play releases

---

## Education & Languages

- **PhD, Radiophysics** | IRE NASU, Kharkiv — numerical modelling of resonant systems in C/C++
- **M.Sc. Radiophysics** | Kharkiv National University

**Languages:** Russian (native) · English (B2) · Bulgarian (A2)