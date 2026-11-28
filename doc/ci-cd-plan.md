# CI/CD чата: план и статус

Цель — тестовые сборки `packages/chat` (Mosty, `com.aleksei.yu.mosty`) из GitHub Actions: iOS в TestFlight, Android во внутреннее тестирование Google Play (трек `internal`). Workflow для notes (`android_deploy.yml`, `ios-testflight.yml`) не меняются.

Решения:
- **Повторяем то, что уже работает для notes:** fastlane в `packages/chat/ios` и `packages/chat/android`, `match` из того же репозитория сертификатов, ключ App Store Connect API, сборка Flutter, потом подпись и загрузка.
- **Запуск только вручную** (`workflow_dispatch`), как у notes: push в ветку сам ничего не выкладывает.
- **Тестов в CI нет:** анализатор и тесты запускает githook перед коммитом, этого пока достаточно.
- **Номер сборки берётся из магазина:** последний номер в TestFlight или максимальный `versionCode` по всем трекам Google Play, плюс 1. CI не коммитит бамп обратно, поэтому номер из `pubspec.yaml` служит только нижней границей. Версию (`0.0.1` в `pubspec.yaml`) владелец меняет руками.
- **TURN-секрет** хранится в GitHub Secrets и передаётся в сборку через `--dart-define=TURN_DEV_SECRET=…`. Без него звонки в тестовых сборках идут только через STUN. Из сборки секрет извлекается (допущение № 3), поэтому сборки получают только тестировщики, а перед любой публичной сборкой секрет меняется (или делается F.6 из [firebase-plan.md](firebase-plan.md)).
- **Конфиги Firebase уже в репозитории** (`google-services.json`, `GoogleService-Info.plist`), поэтому в CI для Firebase ничего не нужно.
- Сборки обфусцируются (`--obfuscate --split-debug-info`), символы сохраняются как artifact запуска. Crashlytics не подключаем.

## Секреты GitHub

| Секрет | Что это | Откуда |
|---|---|---|
| `NOSTR_NOTES_APP_STORE_CONNECT_API_KEY_ID`, `…_ISSUER_ID`, `…_API_KEY_BASE64` | Ключ App Store Connect API | Уже есть: ключ общий для команды `HCYSG3HDXK`, подходит и для Mosty |
| `NOSTR_NOTES_MATCH_PASSWORD`, `NOSTR_NOTES_MATCH_GIT_BASIC_AUTHORIZATION` | Доступ к репозиторию `match` | Уже есть |
| `ANDROID_JSON_KEY_DATA` | Сервисный аккаунт Google Play | Уже есть; в Play Console выдать ему доступ к приложению Mosty |
| `MOSTY_ANDROID_UPLOAD_KEYSTORE` | Upload keystore Mosty в base64 | Новый (шаг C.0) |
| `MOSTY_ANDROID_STORE_PASSWORD`, `MOSTY_ANDROID_KEY_PASSWORD`, `MOSTY_ANDROID_KEY_ALIAS` | Пароли и alias keystore | Новые |
| `MOSTY_TURN_SECRET` | `static-auth-secret` coturn | Новый; то же значение, что `TURN_DEV_SECRET` в `config/turn.dev.json` |

Секреты и файлы, которые из них собираются (`key.properties`, `*.jks`, `AuthKey.p8`, `play_store_credentials.json`), в git не попадают. `key.properties`, `*.jks` и `AuthKey.p8` в `packages/chat` уже в `.gitignore`; `fastlane/play_store_credentials.json` — нет, добавить на шаге C.2.

## Шаги

- **C.0. Ручная подготовка (владелец).**
  - Apple: зарегистрировать App ID `com.aleksei.yu.mosty` в Developer Portal и создать приложение Mosty в App Store Connect. В TestFlight завести группу внутренних тестировщиков: внешним нужна проверка Apple.
  - Google Play: создать приложение Mosty в Play Console и включить Play App Signing. Сгенерировать upload keystore (`keytool -genkey … -alias upload`) и хранить его вне репозитория. **Первый AAB загрузить руками** во внутреннее тестирование: Google Play API не принимает загрузку в приложение, у которого ещё нет ни одной сборки. Добавить тестировщиков в трек `internal`, выдать сервисному аккаунту доступ к приложению.
  - Добавить новые секреты из таблицы.
- **C.1. Подпись Android.** В `packages/chat/android/app/build.gradle.kts` добавить release-подпись из `key.properties`, как в notes. Если файла нет, release-сборка подписывается debug-ключом, чтобы локальный `flutter run --release` работал. R8 сейчас не включён (в notes включён). Если включать, нужны правила ProGuard для `org.webrtc` (их требует `flutter_webrtc`), иначе в release звонок падает. Проверка: локальный `fvm flutter build appbundle --release` с `key.properties` и звонок на release-сборке.
- **C.2. fastlane для Android.** `packages/chat/android/{Gemfile,Gemfile.lock,fastlane/Appfile,fastlane/Fastfile}`, fastlane закреплён на той же версии, что у notes. Lane `internal`: `versionCode` — максимум по всем трекам Google Play плюс 1 (номер из `pubspec.yaml` — нижняя граница), передаётся через `--build-number`, `pubspec.yaml` не меняется. Сборка `flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info`; TURN-секрет из переменной `TURN_DEV_SECRET` передаётся через временный `build/ci-dart-defines.json`, чтобы не попасть в лог команды. Загрузка — `upload_to_play_store(track: 'internal')` с `release_status` из параметра: `draft` по умолчанию (пока приложение в Play Console черновик, API принимает только его), после первой публикации — `completed`. Локально: `FLUTTER="fvm flutter" TURN_DEV_SECRET=… bundle exec fastlane internal` при наличии `fastlane/play_store_credentials.json`.
- **C.3. Workflow Android.** [`.github/workflows/chat-android-internal.yml`](../.github/workflows/chat-android-internal.yml), запуск вручную с выбором `release_status`. `ubuntu-latest`: JDK 17, keystore и `key.properties` из секретов `MOSTY_ANDROID_*`, ключ Google Play из `ANDROID_JSON_KEY_DATA`, Ruby 3.4, Flutter из `.fvmrc`, `melos bootstrap`, `bundle exec fastlane internal`, символы Dart — artifact `chat-android-debug-symbols`.
- **C.4. iOS и TestFlight.**
  - `match appstore` для `com.aleksei.yu.mosty` один раз запустить локально без `readonly`, чтобы профиль попал в репозиторий сертификатов.
  - `packages/chat/ios/{Gemfile,Gemfile.lock,fastlane/Appfile,fastlane/Matchfile,fastlane/Fastfile}`. Lane `beta` — как у notes, с новым bundle id и профилем `match AppStore com.aleksei.yu.mosty`.
  - Workflow `.github/workflows/chat-ios-testflight.yml` на `macos-15` с Xcode 26.3: `flutter build ios --release --no-codesign --obfuscate --split-debug-info=… --dart-define=TURN_DEV_SECRET=…`, затем `bundle exec fastlane beta`. `gym` пересобирает проект по `Generated.xcconfig`, который оставил `flutter build`, поэтому dart-define попадают и в подписанную сборку. Это проверить на первой сборке: в TestFlight-версии звонок с `relay` проходит.
  - Экспортный контроль: ключ `ITSAppUsesNonExemptEncryption` в `Info.plist`, иначе App Store Connect спрашивает о шифровании при каждой сборке. Значение выбирает владелец: в приложении есть DTLS/SRTP (WebRTC) и NIP-44, но это стандартные алгоритмы.
- **C.5. Журнал и документация.** Допущение № 16 в [webrtc-assumptions.md](webrtc-assumptions.md): TURN-секрет в тестовых сборках из CI, кто их получает, когда сменить. Workflow чата в CLAUDE.md, секреты CI в `config/README.md`.

Вне объёма: публичный релиз, скриншоты и описание в магазинах, push-уведомления (APNs и FCM потребуют capability и ключ APNs в Firebase), Crashlytics.

## Статус

| Шаг | Статус |
|---|---|
| C.0 | впереди (владелец) |
| C.1 | готово 2026-11-27: подпись из `key.properties`, первый AAB (0.0.1, versionCode 1) собран локально для ручной загрузки; на устройстве release не проверен |
| C.2 | готово 2026-11-27; lane локально не запускался (он загружает в Google Play) |
| C.3 | готово 2026-11-27; первый запуск — после ручной загрузки первого AAB и секретов (C.0) |
| C.4, C.5 | впереди |
