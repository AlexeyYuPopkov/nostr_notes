# Публикация в каталоге nostrapps.com

Каталог — это один файл `apps.toml` в репозитории сайта, а не форма на
странице. Наша задача — дописать в него одну запись. Файл чужой, в этом
репозитории его нет и быть не должно.

## Куда отправлять: gitworkshop, не GitHub

Кнопка «Submit App» на сайте ведёт на **gitworkshop.dev** — git поверх Nostr
(NIP-34) — в репозиторий `nostrapps-com` автора
`npub180cvv07tjdrrgpa0j7j7tmnyl2yr6yr7l8j4s3evf6u64th6gkwsyjh6w6`.

GitHub-зеркало `1-leo/nostrapps.com` существует, и туда даже присылают PR, но
оно мёртвое: на живом сайте 24 приложения, которых в зеркале нет, а PR с
добавлением приложений висят открытыми месяцами. Патч туда уйдёт в никуда.

## Готовая запись

```toml
[private-notes]
name = "Private Notes"
categories = [ "tools" ]
description = "End-to-end encrypted notes and passwords, stored on your own relays"
gallery = [
  "https://alexeyyupopkov.github.io/preview/shot-1-notes.png",
  "https://alexeyyupopkov.github.io/preview/shot-2-accounts.png",
  "https://alexeyyupopkov.github.io/preview/shot-3-password-generator.png",
  "https://alexeyyupopkov.github.io/preview/shot-4-editor.png"
]
features = [
  "Notes encrypted on-device with NIP-44 — relays only ever hold ciphertext",
  "Optional PIN as a second factor on top of your nsec",
  "Built-in password manager with a password generator",
  "Encrypted export and import of both notes and accounts",
  "Multiple accounts, markdown editor, labels and search",
  "No server and no sign-up — only your keypair"
]
npub = "npub1euhqefc8pg5w0sjqgytqdz0n00kav49gd2rtk9egsxcqvg0j2r3syppchl"
platforms = [ "android", "desktop", "ios", "web" ]
source = "https://github.com/AlexeyYuPopkov/nostr_notes"
thumb = "https://alexeyyupopkov.github.io/preview/icon-256.png"
url = "https://alexeyyupopkov.github.io/"
```

Порядок полей внутри записи — самый частый в каталоге: так устроены 30 записей
из 67, остальные 28 отличаются только отсутствием `source`.

Сам файл отсортирован по алфавиту не строго: из 67 записей 6 стоят не на
месте, причём последние две — в самом конце файла, то есть недавние
добавления просто дописывали. По алфавиту запись встаёт после
`plebeian-market`; дописать в конец тоже не будет расхождением с практикой и
меньше рискует конфликтом, если патч применят не сразу.

## Почему значения такие

**`categories = ["tools"]`** — категории у каталога фиксированные, и «заметок»
среди них нет. `tools` — ближайшая честная, там же Obsidian Nostr Writer и
Lantern. В App Store приложение лежит в Productivity; это независимые
классификаторы, согласовывать их не нужно.

**`platforms`** — допустимы ровно четыре значения, по числу иконок в
`static/` каталога: `android`, `desktop`, `ios`, `web`. macOS идёт как
`desktop`.

**`npub`** обязателен (есть у 66 записей из 67). Это `devNostrPubkey` из
`.env`, переведённый в bech32.

**`url`** — одна ссылка на всю запись, кнопка «скачать» на карточке ведёт
только туда. Web-сборка подходит лучше всего: открывается без установки, а на
экране приветствия есть кнопки в App Store и Google Play, так что один адрес
закрывает все четыре платформы.

## Картинки

Лежат в `packages/notes/web/preview/`. Отдельного хостинга не нужно: Flutter
копирует всё содержимое `web/` в `build/web` дословно, а workflow *Deploy
Flutter Web to GH Pages Repo* публикует это в корень
`AlexeyYuPopkov.github.io`. Положили файл, запустили деплой — он доступен по
`https://alexeyyupopkov.github.io/preview/<файл>`.

Выкатки ручные, автотриггеры отключены. И `keep_files: true` означает, что
удаление файла из репозитория **не** убирает его с сайта — чистить надо в
репозитории Pages.

Четыре скриншота и одна ориентация — не случайность. Галерея каталога это
сетка: 4 колонки шире 991px, 2 до 991px, 1 до 767px, то есть четыре картинки
раскладываются ровно при любой ширине. У изображений `width: 100%` и нет
`object-fit`, поэтому обрезки нет, а высоту ряда задаёт самый высокий
элемент — вертикальный и горизонтальный скриншоты рядом дали бы ряд, в
котором горизонтальный висит в пустоте.

Хост `cdn.satellite.earth`, на котором лежат 237 из 270 картинок каталога,
отдаёт 502 — у большинства карточек картинки сейчас просто не грузятся.
Поэтому свои держим у себя.

## Как обновить запись потом

Поменять текст здесь, отправить новый патч тем же путём. Если меняются
картинки — сначала деплой Pages, потом патч: URL должны отдавать 200 до того,
как каталог на них сошлётся.
