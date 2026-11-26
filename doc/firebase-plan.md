# Firebase в чате: план и статус

Firebase подключён только к `packages/chat` (проект `mosty-1b2f1`, приложения iOS и Android `com.aleksei.yu.mosty`). Notes и остальные пакеты его не используют.

Зачем: адреса серверов звонков и флаги можно менять без новой сборки (Remote Config), в будущем — пуши о входящих звонках (FCM) и выдача TURN-кредов с сервера.

Ограничения:
- **Remote Config не для секретов**: значения читает любой, у кого есть приложение. Секрет TURN остаётся в `config/turn.dev.json` (допущение № 3 в [webrtc-assumptions.md](webrtc-assumptions.md)), пока нет шага F.6.
- **Значения по умолчанию в коде остаются**: на них приложение работает при первом запуске и офлайн; Remote Config их только переопределяет.
- **Analytics не подключаем.** Firebase всё равно создаёт идентификатор установки и ходит на серверы Google — это запишется в журнал допущений на шаге F.5.
- В значения Remote Config не выносятся: тексты интерфейса (l10n), значение тега `client`, kind событий и константы протокола.

## Шаги

- **F.0. Подготовка.** Android `applicationId` = `com.aleksei.yu.mosty`, проект в консоли Firebase, приложения iOS и Android, `flutterfire` CLI.
- **F.1. Подключение.** `firebase_core`, `firebase_remote_config`; `flutterfire configure` в `packages/chat` (`lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, `firebase.json`); `Firebase.initializeApp` в `main.dart`. Конфиги Firebase коммитятся (по документации Google это не секреты). CI собирает только notes, поэтому для чата там менять нечего.
- **F.2. Обёртка `RemoteSettings`.** Интерфейс в `chat/lib/common/domain/remote_settings.dart`; разбор значений и значения по умолчанию — `ParsedRemoteSettings` в `chat/lib/common/data/remote_settings/`; загрузка — `FirebaseRemoteSettings.load`. При старте применяется то, что скачано в прошлый раз, свежие значения скачиваются в фоне к следующему запуску: старт не ждёт сеть, и значения не меняются в работающем приложении. Неверное значение в консоли заменяется значением по умолчанию. Регистрируется в DI (`Di.registerUnauthModules(remoteSettings: …)`); тесты передают `ParsedRemoteSettings.defaults()`.
- **F.3. Звонки.** `CallConfig.from(RemoteSettings)`: адрес сигналинга, STUN, TURN, «только relay», имя клиента и таймаут ответа. Таймаут доходит до `call(answerTimeout:)` и `awaitCall(offerTimeout:)` через `CallConnection.answerTimeout`, до срока свежести приглашения — через `WatchIncomingCallInvitesUsecase.inviteLifetime`. Пакет `webrtc_call` о Firebase не знает. Для локальной отладки dart-define `SIGNALING_URL` и `CALL_RELAY_ONLY=true` перекрывают Remote Config; `TURN_DEV_SECRET` и `TURN_TTL_SECONDS` остаются только в dart-define. Example остаётся на dart-define. Сделано 2026-11-26.
- **F.4. Наш релей в чате.** Параметр `chat_relay` (по умолчанию `wss://alekseiiapi.site:8443`) добавляется к релеям, которые чат предлагает выбрать (онбординг и настройки): `RelaysListRepoImpl(suggestedRelays: …)` в DI чата. Выбор пользователя не меняется: релей не отмечается сам. В notes список без изменений. Сделано 2026-11-26.
- **F.5. Документация.** Запись в журнале допущений (идентификатор установки, серверы Google), CLAUDE.md, `config/README.md`.
- **F.6. Выдача TURN-кредов с сервера** (предложение, не подтверждено). Cloud Function с проверкой App Check выдаёт короткоживущие креды; секрет уходит из сборки, закрывается допущение № 3 и §10 [webrtc-backend.md](webrtc-backend.md). Чат получает креды через `iceServers` из шага 7.3. Нужен тариф Blaze. До любой публичной сборки — сменить засвеченный TURN-секрет.

## Параметры Remote Config

Ключи — `RemoteSettingsKeys`, значения по умолчанию — `RemoteSettingsDefaults` (`chat/lib/common/data/remote_settings/parsed_remote_settings.dart`). В консоли все параметры задаются строками.

| Ключ | Формат | По умолчанию | Кто читает |
|---|---|---|---|
| `signaling_url` | `wss://…` или `ws://…` | `wss://alekseiiapi.site:8086/ws` | `CallConfig` (dart-define `SIGNALING_URL` перекрывает) |
| `stun_urls` | через запятую | `stun:alekseiiapi.site:3478` | `CallConfig` |
| `turn_urls` | через запятую | `turn:…:3478?transport=udp`, `turn:…:3478?transport=tcp`, `turns:…:443?transport=tcp` | `CallConfig` |
| `call_answer_timeout_seconds` | целое > 0 | `45` | `CallConfig`: ожидание ответа и offer, срок свежести приглашения |
| `call_relay_only` | `true` / `false` | `false` | `CallConfig` (dart-define `CALL_RELAY_ONLY=true` включает и без Remote Config) |
| `signaling_client_name` | строка | `Mosty` | `CallConfig` |
| `chat_relay` | `wss://…` или `ws://…` | `wss://alekseiiapi.site:8443` | список предлагаемых релеев чата |

Шаблон с этими параметрами и значениями по умолчанию — [`packages/chat/firebase/remote_config_template.json`](../packages/chat/firebase/remote_config_template.json). Загрузка в консоли: Remote Config → меню ⋮ → «Publish from a file». Загрузка заменяет весь текущий шаблон проекта. При изменении ключей или значений по умолчанию в коде шаблон обновляется вместе с ними.

В debug-сборке значения скачиваются при каждом запуске, в release — не чаще раза в час. Новое значение из консоли вступает в силу со следующего запуска.

## Статус

| Шаг | Статус |
|---|---|
| F.0 | готово |
| F.1 | готово 2026-11-26 |
| F.2 | готово 2026-11-26 |
| F.3 | готово 2026-11-26, на устройствах не проверено |
| F.4 | готово 2026-11-26 |
| F.5 | впереди |
| F.6 | не подтверждён |
