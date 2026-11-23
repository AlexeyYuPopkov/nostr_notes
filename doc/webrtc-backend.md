# Backend для WebRTC-звонков и Nostr-чата — документация

Документ описывает всё, что развернуто на VPS: что где работает, как это проверить, как обслуживать и как подключать клиент (Flutter). Написан для владельца проекта и для агента (Claude).

Состояние на: 2026-11-19. Всё помеченное **[не проверено]** в этой сессии не тестировалось и требует проверки перед использованием.

---

## 1. Назначение и ограничения дизайна

- Цель: прототип 1-1 видеозвонка на `flutter_webrtc` (iOS/Android) со **своим** бэкендом вместо чужих сервисов.
- В приложении уже есть 1-1 чат на Nostr. Звонок должен **начинаться из чата**, но **сигналинг звонка НЕ идёт через Nostr** (решение владельца). Единственная связь чата и звонка — сообщение-приглашение в чате (`call_invite`, см. §8.1).
- Свой Nostr-релей нужен, чтобы (а) чат работал на своей инфраструктуре и (б) пользователи могли **искать собеседника по имени профиля** (NIP-50 по kind 0).
- Бэкенд — демо-уровня: у сигналинг-сервера нет аутентификации, а защита релея от спама только частичная (§6.5, §10).

## 2. Архитектура

```
                          Интернет
   ┌───────────────────────────┼─────────────────────────────┐
   │ Flutter-клиент            │                             │
   │  ├─ Nostr-чат ───wss://alekseiiapi.site:8443──┐         │
   │  ├─ сигналинг ───wss/https://alekseiiapi.site:8086──┐   │
   │  └─ медиа/ICE ──stun/turn(s):3478 / 443 / UDP-диапазон──┼┐
   └───────────────────────────┼─────────────────────────┼──┘│
                               ▼                         ▼   ▼
                 VPS 38.180.2.49 (Debian 13, Docker, без firewall)
   ┌──────────────────────────────────────────────────────────────┐
   │ caddy (host net)  :8443  TLS ──► 127.0.0.1:6969              │
   │ nostr-relay       127.0.0.1:6969  (LMDB + Whoosh FTS)        │
   │ signaling (flutter-webrtc-server, host net)  :8086 TLS       │
   │ coturn (host net) :3478 udp/tcp, :443 tls (turns), UDP relay │
   │ certbot (хост)    Let's Encrypt → deploy-hook копирует certs │
   └──────────────────────────────────────────────────────────────┘
```

Домен: `alekseiiapi.site`, A-запись → `38.180.2.49`.

## 3. Эндпоинты и порты

| Сервис | Адрес для клиента | Порт на хосте | Примечание |
|---|---|---|---|
| Nostr-релей (NIP-11 + WebSocket) | `wss://alekseiiapi.site:8443` | 8443 (Caddy) → 127.0.0.1:6969 | поиск NIP-50, фильтр по тегу `client` |
| Сигналинг | `https://alekseiiapi.site:8086` (WebSocket на том же порту) | 8086 | Go, flutter-webrtc-server; **без аутентификации** |
| STUN/TURN | `stun:alekseiiapi.site:3478`, `turn:alekseiiapi.site:3478?transport=udp\|tcp` | 3478 udp+tcp | REST-авторизация по секрету |
| TURN over TLS | `turns:alekseiiapi.site:443?transport=tcp` | 443 tcp | пробивает сети, где открыт только 443 |
| TURN relay-порты | — | UDP 49160–49200 | диапазон узкий (41 порт) → ~20 одновременных звонков |

Порт 443 занят coturn, поэтому веб-сервисы вынесены на 8086/8443. Порт 80 нужен certbot при продлении (standalone) — см. §9.3.

Firewall на VPS нет (ufw отсутствует), все порты открыты. Если провайдер/админ позже включит фильтрацию, открыть: 3478/udp+tcp, 443/tcp, 49160–49200/udp, 8086/tcp, 8443/tcp, 80/tcp.

## 4. Инвентарь сервера

Доступ: веб-терминал в панели хостинга (is*hosting, Virtual Server #353714), root. Терминал иногда рвётся («Client disconnected») — перезагрузить страницу. **Не использовать `set -e` в интерактивном шелле** (убивает сессию).

Docker: пакет `docker.io` (Debian 13). Все контейнеры с `--restart unless-stopped`.

| Контейнер | Образ | Сеть | Монтирования | Файлы на хосте |
|---|---|---|---|---|
| `coturn` | `coturn/coturn` | host | конфиг и `/opt/coturn/certs:/certs:ro` | `/opt/coturn/turnserver.conf`, `/opt/coturn/certs/` |
| `signaling` | собран локально из `/opt/flutter-webrtc-server/Dockerfile` | host | `/opt/flutter-webrtc-server/configs:/app/configs:ro` | `/opt/flutter-webrtc-server/` |
| `nostr-relay` | собран локально из `/opt/nostr-relay/Dockerfile` | порт `127.0.0.1:6969:6969` | config, validators, data | `/opt/nostr-relay/` |
| `caddy` | `caddy:2` | host | `/opt/caddy/Caddyfile:/etc/caddy/Caddyfile:ro`, `/opt/coturn/certs:/certs:ro` | `/opt/caddy/Caddyfile` |

Точные команды запуска **восстановите через `docker inspect <name>`** — ниже они приведены как справка (для coturn/signaling точный путь монтирования конфига не перепроверялся).

Дополнительно на хосте: `sysctl net.ipv4.ip_unprivileged_port_start=0` (чтобы не-root процессы могли слушать порты <1024), midnight commander (`mc`).

## 5. Сертификаты (Let's Encrypt)

- Сертификат на `alekseiiapi.site` выпущен certbot (standalone). Живые файлы: `/etc/letsencrypt/live/alekseiiapi.site/`.
- Хук `/etc/letsencrypt/renewal-hooks/deploy/copy.sh` после каждого выпуска/продления копирует сертификаты в:
  - `/opt/coturn/certs/{fullchain.pem,privkey.pem}` (для coturn и caddy),
  - `/opt/flutter-webrtc-server/configs/certs/{cert.pem,key.pem}` (для signaling),
  - делает `chmod 644` на копии и вызывает `docker restart coturn signaling` и `docker restart caddy`.
- Автопродление (systemd-таймер certbot) и `certbot renew --dry-run` **[не проверено]**. Для standalone-режима порт 80 должен быть свободен в момент продления. Проверить: `systemctl list-timers | grep certbot` и `certbot renew --dry-run`.

## 6. Компоненты

### 6.1 coturn (STUN/TURN)

Конфиг `/opt/coturn/turnserver.conf` (секрет не приводится):

```
listening-port=3478
tls-listening-port=443
external-ip=38.180.2.49
min-port=49160
max-port=49200
fingerprint
use-auth-secret
static-auth-secret=<СЕКРЕТ — только на сервере>
realm=alekseiiapi.site
cert=/certs/fullchain.pem
pkey=/certs/privkey.pem
no-multicast-peers
no-cli            # deprecated-предупреждение, безвредно, можно удалить
```

Проверено из браузера (Trickle ICE): релей-кандидаты получены по UDP, TCP и `turns:443`.

**REST-авторизация TURN** (`use-auth-secret`): временные учётные данные считаются из общего секрета.

- `username = "<unix_время_истечения>:<произвольный_id>"`, например `1795200000:peerPubkey`
- `credential = base64( HMAC-SHA1( secret, username ) )`

Dart (пакет `crypto`):
```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

({String username, String credential}) turnCreds(String secret, String userId,
    {Duration ttl = const Duration(hours: 1)}) {
  final expiry = DateTime.now().toUtc().add(ttl).millisecondsSinceEpoch ~/ 1000;
  final username = '$expiry:$userId';
  final mac = Hmac(sha1, utf8.encode(secret)).convert(utf8.encode(username));
  return (username: username, credential: base64.encode(mac.bytes));
}
```
**Важно:** секрет НЕЛЬЗЯ зашивать в клиент. Сейчас эндпоинта выдачи credentials нет (§10, TODO). Для разработки можно временно считать на клиенте из dev-секрета, но до релиза нужен сервис выдачи.

Рекомендуемая конфигурация `iceServers` клиента:
```json
[
  {"urls": ["stun:alekseiiapi.site:3478"]},
  {"urls": ["turn:alekseiiapi.site:3478?transport=udp",
            "turn:alekseiiapi.site:3478?transport=tcp",
            "turns:alekseiiapi.site:443?transport=tcp"],
   "username": "<expiry:id>", "credential": "<base64 hmac>"}
]
```
Для проверки TURN используйте переключатель `iceTransportPolicy: relay` (только релей-кандидаты).

### 6.2 Сигналинг-сервер (flutter-webrtc-server)

- Исходники: клонированный репозиторий в `/opt/flutter-webrtc-server`; Dockerfile (golang:1.22-alpine → alpine) собирает `./cmd/server`, копирует `configs` и `web`, EXPOSE 8086.
- `configs/config.ini`: `domain=alekseiiapi.site`, пути к cert/key (`configs/certs/cert.pem`, `key.pem`), порт 8086. Встроенный TURN из этого сервера **не используется** (используем coturn); его секция в конфиге — мусор, `public_ip=127.0.0.1`, порт 19302.
- Проверено: `https://alekseiiapi.site:8086` отдаёт валидный Let's Encrypt-сертификат.
- Это демо-сервер: **нет аутентификации**, пиры по произвольным id. На клиенте он спрятан за абстракцией `SignalingChannel` (§8.2), чтобы сервер можно было заменить.

#### Протокол сигналинга

Источник: исходники `flutter-webrtc-server` (master, `51ca22c`: `pkg/signaler/signaler.go`, `pkg/websocket/*.go`) и `signaling.dart` из `flutter-webrtc-demo`. Проверено на нашем сервере 2026-11-21 двумя тестовыми клиентами. Версию клона на VPS не сверяли.

- WebSocket: `wss://alekseiiapi.site:8086/ws`. Все сообщения — JSON-текст `{"type": "<тип>", "data": <объект>}`.
- Сервер раз в 5 с шлёт строку `{}` без `type` (свой ping). Клиент такие сообщения пропускает.
- Сервер ничего не хранит. Пир существует, пока открыт его сокет, и сообщения пиру не в сети не доставляются.

| Тип | Кто шлёт | `data` | Что делает сервер |
|---|---|---|---|
| `new` | клиент, сразу после открытия сокета | `{"id", "name", "user_agent"}` | регистрирует пира (тот же `id` с другого сокета перезаписывает старую запись), всем шлёт `peers` |
| `peers` | сервер | `[{"id", "name", "user_agent"}, …]` (вместе с самим получателем) | — |
| `offer` | клиент | `{"from", "to", "session_id", "media", "description": {"sdp", "type"}}` | пересылает пиру `to` всё сообщение без изменений |
| `answer` | клиент | `{"from", "to", "session_id", "description": {"sdp", "type"}}` | так же |
| `candidate` | клиент | `{"from", "to", "session_id", "candidate": {"candidate", "sdpMid", "sdpMLineIndex"}}` | так же |
| `bye` | клиент | `{"from", "session_id"}` | делит `session_id` по `-` и шлёт **обоим** участникам `{"to", "session_id"}` (без `from`) |
| `keepalive` | клиент | любое | возвращает отправителю то же сообщение |
| `error` | сервер | `{"request", "reason"}` | например, `Peer [x] not found ` при `to`, которого нет в сети |
| `leave` | сервер, когда чей-то сокет закрылся | строка | см. ниже |

Особенности, которые клиент должен учитывать:
- `session_id` — `"<id звонящего>-<id принимающего>"`. Сервер режет его по `-` и ждёт ровно две части, поэтому **id пира не должен содержать `-`**. Hex-pubkey подходит, UUID нет.
- `leave` **сломан**: в `data` приходит id самого получателя, а не ушедшего пира, и может прийти несколько раз. Уход собеседника определять по отсутствию его id в следующем `peers`.
- `media` в `offer` — `"video"`, `"audio"` или `"data"`. Сервер его не читает.
- Сервер держит пиров в map без блокировок. При одновременных подключениях возможны гонки (демо-код).

#### `/api/turn` не использовать

`GET /api/turn?service=turn&username=<x>` отвечает `{"username", "password", "ttl", "uris"}`. Учётные данные считаются на ключе, зашитом в код сервера (`flutter-webrtc-turn-server-shared-key`), а не на секрете coturn, и `uris` указывают на `turn:127.0.0.1:19302` из секции `[turn]` конфига. Для нашего coturn эти данные не подходят. Сервис выдачи кредов — TODO (§10).

### 6.3 Nostr-релей (nostr-relay)

- Проект: `nostr-relay` (Python, BSD-3, v1.14 от июня 2024; репозиторий code.pobblelabs.org/fossil/nostr_relay). Образ: `python:3.11-slim` + `pip install "nostr-relay[lmdb]"`.
- Хранилище: **LMDB** (`nostr_relay.storage.kv.LMDBStorage`), данные в `/opt/nostr-relay/data/lmdb`. Полнотекстовый поиск (Whoosh) в этом проекте доступен **только** в LMDB-хранилище, поэтому SQLite не подходит. Старый файл `/opt/nostr-relay/data/nostr.sqlite3` — остаток первой попытки, не используется.
- Конфиг `/opt/nostr-relay/config.yaml` (на основе `default-config.yaml` пакета):
  - `relay_name: alekseiiapi relay`
  - `storage.class: nostr_relay.storage.kv.LMDBStorage`, `storage.path: /app/data/lmdb`
  - `storage.validators`: `is_not_too_large`, `is_signed`, `is_recent`, `is_not_hellthread`, **`validators_custom.has_client_tag`**
  - `fts_enabled: true` (в конце файла; `fts_kinds` по умолчанию (1, 0), индексируются kind 0 и kind 1)
  - `gunicorn.bind: 0.0.0.0:6969`
  - `authentication.enabled: false` (NIP-42 выключен)
- **Ловушка конфига:** все ключи секции `storage:` кроме `class`, `pool_size` и `validators` уходят в `lmdb.open(**options)`. Ключи `num_concurrent_reqs` / `num_concurrent_adds` из конфига по умолчанию (для SQLite) ломают запуск воркера (`TypeError: unrecognized keyword argument`, gunicorn: «Worker failed to boot» без трейсбэка). Их надо удалить.
- Команда запуска контейнера:
```
docker run -d --name nostr-relay --restart unless-stopped \
  -p 127.0.0.1:6969:6969 -e PYTHONPATH=/app/extra \
  -v /opt/nostr-relay/config.yaml:/app/config.yaml:ro \
  -v /opt/nostr-relay/validators_custom.py:/app/extra/validators_custom.py:ro \
  -v /opt/nostr-relay/data:/app/data \
  nostr-relay nostr-relay -c /app/config.yaml serve
```
- NIP-11 сообщает NIP: 1, 2, 5, 9, 11, 12, 15, 20, 26, 33, 40, **50**.

### 6.4 Caddy

`/opt/caddy/Caddyfile`:
```
{
	admin off
	auto_https off
}

alekseiiapi.site:8443 {
	tls /certs/fullchain.pem /certs/privkey.pem
	reverse_proxy 127.0.0.1:6969
}
```
TLS-терминация и проксирование WebSocket на релей. Сертификаты из `/opt/coturn/certs` (обновляются хуком, после чего Caddy перезапускается).

### 6.5 Правила записи и фильтр спама

`/opt/nostr-relay/validators_custom.py`:
```python
from nostr_relay.errors import StorageError

REQUIRED_CLIENT = "996e10ba"

def has_client_tag(event, config):
    if event.kind == 22242:  # NIP-42 AUTH не хранится
        return
    for t in event.tags:
        if len(t) >= 2 and t[0] == "client" and t[1] == REQUIRED_CLIENT:
            return
    raise StorageError("rejected: missing client tag")
```
- **Каждое публикуемое событие любого kind** (кроме 22242) обязано содержать тег `["client","996e10ba"]`. Иначе: `["OK", id, false, "rejected: missing client tag"]`.
- Для gift wrap (kind 1059) тег должен стоять на **внешней** обёртке: внутренние события релей не видит.
- Релей замедляет соединение, которое шлёт отклонённые события (задержка удваивается: 2, 4, 8 … с, лог `Throttling N`).
- Это **частичная защита**: значение тега видно в трафике, любой может его скопировать. Настоящий контроль — роли/белый список (§6.6).
- Тестовые вызовы проверены: без тега, с чужим значением и тег без значения отклоняются; с правильным тегом принимаются, лишние теги допустимы.

### 6.6 Чего НЕ включено (решения на будущее)

- **NIP-42 (AUTH)** выключен. Включение защитило бы метаданные: чтение событий, адресованных pubkey X (тег `p`, в основном kind 1059), только владельцем ключа X. Сейчас любой может подписаться на чужие `#p` и увидеть метаданные переписки (содержимое зашифровано). Для включения: `authentication.enabled: true`, `authentication.valid_urls` обязан совпадать с публичным URL (`wss://alekseiiapi.site:8443`), клиент должен отвечать на `AUTH`. Схему `authentication.actions` в конфиге **[не изучена]**.
- Сам по себе AUTH не защищает от спама (ключ можно создать бесплатно) — нужен белый список или приглашения.
- **Роли пользователей** хранятся в хранилище релея (LMDB), не в YAML. Читаются в момент AUTH, поэтому изменения действуют без рестарта (на следующем AUTH пользователя). Из исходников: CLI `nostr-relay role` (подкоманды `set` с `--roles`, и просмотр), методы `storage.set_auth_roles / get_auth_roles / get_all_auth_roles`. Готового HTTP admin-API нет — при необходимости делается маленький сервис рядом, вызывающий CLI через `docker exec`. **[не проверено на практике]**
- В конфиге есть и `pubkey_whitelist` / `pubkey_blacklist` (валидаторы `is_author_whitelisted/blacklisted`, исходники), PoW (`is_pow`, `require_pow`) — не включены.

## 7. Поиск собеседника (NIP-50) — что работает

Запрос: `["REQ","id",{"kinds":[0],"search":"<строка>","limit":20}]`. Индексируются поля профиля (`name`, `display_name`, `about` — проверено на `name`; остальные поля отдельно **не проверялись**). Проверено на латинице и кириллице:

| Запрос | Результат |
|---|---|
| целое слово (`alexey`, `Алексей`), любой регистр | находит |
| несколько слов (`maria ivanova`) | находит |
| префикс **с** `*` (`alex*`, `ale*`, `алек*`) | находит |
| префикс без `*` (`alex`) | 0 результатов |
| 1–3 символа без `*` (`bob`) **или короткий с `*` (`bo*`)** | фильтр игнорируется — возвращаются ВСЕ профили (до `limit`) |

**Правила для клиента:**
1. Отправлять `"<текст>*"` и только когда введено ≥ 3 символов; короче — вообще не запрашивать релей.
2. Всегда задавать `kinds:[0]` и `limit`.
3. Новые профили индексируются с задержкой (в тестах хватало 3–4 с).
4. Запрос без `kinds` ищет и по заметкам kind 1.

## 8. Интеграция клиента

### 8.1 Связь чат → звонок

Единственный мост — сообщение в существующем чате (тип `call_invite`):
```json
{"type": "call_invite", "callId": "<uuid>", "video": true}
```
Принимающий клиент по приглашению открывает экран звонка и подключается к сигналингу с этим `callId`. Идентификатор пира — **pubkey** Nostr (демо-сервер сам ничего не проверяет). Опционально позже: подпись challenge ключом Nostr (в духе NIP-42) для сигналинга и выдачи TURN-credentials.

### 8.2 Рекомендованная структура клиента

- Основа: `flutter-webrtc-demo` + `flutter_webrtc`.
- Интерфейс `SignalingChannel` (абстракция над транспортом сигналинга) + `CallService` (состояния звонка, ICE restart, переподключение).
- Свои `iceServers` (§6.1), переключатель relay-only, оверлей статистики (`getStats`) для проверки типа канала (host/srflx/relay).
- Nostr-чат подключать к `wss://alekseiiapi.site:8443`, всем публикациям добавлять тег `["client","996e10ba"]`.

### 8.3 Чего нет и что нужно сделать до релиза

- Сервис выдачи TURN-credentials (небольшой сервер, например на Node; аутентификация подписью pubkey), чтобы секрет не жил в клиенте.
- Аутентификация сигналинга.

## 9. Эксплуатация

### 9.1 Статус и логи
```
docker ps
docker logs --tail 50 nostr-relay
docker logs --tail 50 caddy
docker logs --tail 50 coturn
docker logs --tail 50 signaling
curl -s -H 'Accept: application/nostr+json' http://127.0.0.1:6969/   # NIP-11 локально
```

### 9.2 Перезапуск
```
docker restart nostr-relay      # после правки config.yaml / validators_custom.py
docker restart caddy            # после правки Caddyfile или обновления сертификатов
docker restart coturn signaling
```

### 9.3 Сертификаты
Продление: `certbot renew` (хук сам скопирует файлы и перезапустит контейнеры). Для проверки: `certbot renew --dry-run` **[не выполнялось]**. Порт 80 должен быть свободен.

### 9.4 Смена секрета TURN
1. Сгенерировать: `openssl rand -hex 32`.
2. Заменить `static-auth-secret` в `/opt/coturn/turnserver.conf`.
3. `docker restart coturn`.
4. Обновить секрет там, где считаются credentials (сервис выдачи). Старые временные credentials перестанут работать.

### 9.5 Резервная копия релея
Данные — каталог `/opt/nostr-relay/data/lmdb` (+ индекс Whoosh внутри него). Для консистентной копии остановить контейнер (`docker stop nostr-relay`), скопировать каталог, запустить. Автобэкапа нет.

### 9.6 Обновление nostr-relay
Пересобрать образ (`docker build -t nostr-relay /opt/nostr-relay`) и пересоздать контейнер командой из §6.3. Версия 1.14 от июня 2024 — проект малоактивный; следить за совместимостью конфигурации.

### 9.7 Очистка тестовых данных
В релее остались тестовые профили (`Alexey Test`, `Алексей Тестов`, `Мария Иванова`, `Maria Ivanova`, `Bob Builder`) и тестовые заметки kind 1. Удалить: `nostr-relay purge` (CLI, подкоманда есть; синтаксис см. `--help`) или очистить `data/lmdb` при остановленном релее.

## 10. Известные проблемы и TODO

1. **Секрет TURN засветился** в переписке при настройке → сменить (§9.4).
2. Удалить `no-cli` из конфига coturn.
3. Сервис выдачи TURN-credentials + аутентификация сигналинга.
4. Решить: включать ли NIP-42 и белый список/приглашения (§6.6).
5. Диапазон TURN-портов узкий (49160–49200): при росте нагрузки расширить `min-port/max-port` и перезапустить coturn.
6. Нет бэкапов, нет мониторинга, нет firewall.
7. Релей читаем всеми (профили/поиск открыты намеренно).

## 11. Тесты (скрипты в `/opt/nostr-relay/`)

Запуск через временный контейнер на хосте:
```
docker run --rm --network host -v /opt/nostr-relay/t3.py:/t3.py python:3.11-slim \
  sh -c 'pip install -q coincurve websockets; python /t3.py'
```
- `t.py` — публикует тестовые профили/заметку и проверяет варианты поиска (латиница/кириллица). **Внимание:** публикует без тега `client` → теперь будет отклонён (нужно добавить тег в `ev()`).
- `t2.py` — wildcard- и многословный поиск по kind 0 (запросы собираются из кодов символов, чтобы не печатать кириллицу в терминале).
- `t3.py` — проверка фильтра по тегу `client` (5 случаев); итог смотреть в `docker logs nostr-relay` (`added` / `Auth error rejected`).

Проверка снаружи: из браузера `fetch('https://alekseiiapi.site:8443/', {headers:{Accept:'application/nostr+json'}})` и `new WebSocket('wss://alekseiiapi.site:8443')` с REQ-поиском — выполнено, работает с валидным сертификатом.

## 12. Выбор технологий (кратко, зачем так)

- **strfry** отвергнут: нет полнотекстового поиска (PR открыт, но не в main).
- **rnostr**: поиск экспериментальный и индексирует только kind 1 → для профилей не подходит.
- **nostpy-relay**: требует Postgres+Redis+NGINX, тяжёлый (≥2 ГБ), владелец уже тестировал.
- **n0str** (Bun, AGPL; по умолчанию БД в памяти) — запасной вариант, если nostr-relay не устроит.
- Другие кандидаты: khatru+Bleve (индексирует kind 0), Saltivka.
- Выбран **nostr-relay**: ставится одним pip, поиск по kind 0 проверен.


## 13. Сторонние решения (3rd party)

Только то, что реально используется. Отвергнутые варианты — в §12.

1. [nostr-relay](https://code.pobblelabs.org/fossil/nostr_relay) — Nostr-релей на Python (v1.14), хранилище LMDB, полнотекстовый поиск NIP-50. Используем как релей для чата и для поиска пользователей по имени профиля (kind 0), см. §6.3, §7.
2. [coturn](https://github.com/coturn/coturn) — STUN/TURN-сервер. Используем для STUN, TURN (UDP/TCP 3478) и TURN over TLS (443) с REST-авторизацией по общему секрету, см. §6.1.
3. [flutter-webrtc-server](https://github.com/flutter-webrtc/flutter-webrtc-server) — демо-сигналинг-сервер на Go. Используем только как сигналинг (WebSocket, обмен offer/answer/candidate); его встроенный TURN и `/api/turn` не используем, см. §6.2.
4. [flutter_webrtc](https://github.com/flutter-webrtc/flutter-webrtc) — Flutter-плагин WebRTC. Используем в клиенте для видео- и аудиозвонков 1-1 на iOS/Android, см. §8.2.
5. [flutter-webrtc-demo](https://github.com/flutter-webrtc/flutter-webrtc-demo) — демо-приложение к плагину. Берём как основу клиента (логика сигналинга в `signaling.dart`), см. §8.2.
6. [Caddy](https://github.com/caddyserver/caddy) — веб-сервер и reverse proxy. Используем для TLS-терминации и проксирования WebSocket на релей (8443 → 127.0.0.1:6969), см. §6.4.
7. [Certbot](https://certbot.eff.org) + [Let's Encrypt](https://letsencrypt.org) — бесплатные TLS-сертификаты для `alekseiiapi.site` и их автопродление; deploy-hook раздаёт сертификаты coturn, caddy и signaling, см. §5.
8. [Docker](https://www.docker.com) (пакет `docker.io` в Debian 13) — запуск всех сервисов в контейнерах, см. §4.
9. [LMDB](https://www.symas.com/lmdb) и [Whoosh](https://github.com/mchaput/whoosh) — хранилище и движок полнотекстового индекса внутри nostr-relay; отдельно не разворачиваются.
10. [crypto](https://pub.dev/packages/crypto) (Dart) — HMAC-SHA1 для временных TURN-credentials на клиенте, см. §6.1.
11. [coincurve](https://github.com/ofek/coincurve) и [websockets](https://github.com/python-websockets/websockets) (Python) — подписи событий и WebSocket-клиент в тестовых скриптах релея, см. §11.
