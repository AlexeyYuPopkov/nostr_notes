import random

# увеличение датасета аугментациями: синонимы, шумовые токены, ссылки, валюты, случайный регистр, перестановка слов, опечатки
# --- словари замен ---
SYNONYMS = {
    "Work": {
        "deploy": ["release", "ship", "rollout"],
        "fix": ["resolve", "patch"],
        "bug": ["issue", "error"],
        "api": ["endpoint", "service"],
        "docker": ["container"],
    },
    "Finance": {
        "paid": ["spent", "sent"],
        "купил": ["приобрел"],
        "деньги": ["средства"],
        "usd": ["$"],
        "eur": ["€"],
    },
    "Travel": {
        "flight": ["plane", "airplane"],
        "hotel": ["stay", "room"],
        "trip": ["journey"],
        "поезд": ["электричка"],
    },
    "Security": {
        "password": ["pass", "pwd"],
        "token": ["key", "secret"],
        "backup": ["snapshot"],
    },
}

NOISE_TOKENS = [
    "ok",
    "done",
    "check",
    "tmp",
    "note",
    "!",
    "...",
    "срочно",
    "быстро",
    "потом",
]

LINKS = ["https://example.com", "http://test.dev", "https://site.org"]

CURRENCIES = ["usd", "eur", "$", "€", "руб"]

# --- функции ---


def replace_synonyms(text, cls):
    words = text.split()
    new_words = []
    for w in words:
        lw = w.lower()
        if cls in SYNONYMS and lw in SYNONYMS[cls]:
            if random.random() < 0.3:
                w = random.choice(SYNONYMS[cls][lw])
        new_words.append(w)
    return " ".join(new_words)


def inject_noise(text):
    if random.random() < 0.3:
        text += " " + random.choice(NOISE_TOKENS)
    return text


def inject_link(text, cls):
    # Добавляем ссылку только для Bookmarks, чтобы не размывать паттерн остальных классов.
    if cls == "Bookmarks" and random.random() < 0.3:
        text += " " + random.choice(LINKS)
    return text


def inject_currency(text, cls):
    if cls in ["Finance", "Personal"] and random.random() < 0.3:
        text += f" {random.randint(5,500)} {random.choice(CURRENCIES)}"
    return text


def random_case(text):
    if random.random() < 0.2:
        return text.upper()
    if random.random() < 0.2:
        return text.lower()
    return text


def shuffle_words(text, cls):
    if cls != "Journal":
        words = text.split()
        if len(words) > 3 and random.random() < 0.2:
            random.shuffle(words)
        return " ".join(words)
    return text


def add_typos(text):
    if text and random.random() < 0.2:
        i = random.randint(0, len(text) - 1)
        return text[:i] + text[i] * 2 + text[i + 1 :]
    return text


# --- главный augment ---


def augment_text(text, cls):
    t = text

    t = replace_synonyms(t, cls)
    t = inject_noise(t)
    t = inject_link(t, cls)
    t = inject_currency(t, cls)
    t = shuffle_words(t, cls)
    t = add_typos(t)
    t = random_case(t)

    return t


def augment_dataset(dataset, n_aug=3):
    augmented = []

    for item in dataset:
        text = item[0]
        cls = item[1]

        augmented.append(item)

        for _ in range(n_aug):
            new_text = augment_text(text, cls)
            augmented.append((new_text, cls))

    return augmented
