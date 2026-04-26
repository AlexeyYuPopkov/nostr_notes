import json
import re
import json
from collections import Counter

# from nltk.stem import SnowballStemmer

# _stemmer_ru = SnowballStemmer("russian")
# _stemmer_en = SnowballStemmer("english")

# Простая эвристика: если слово содержит кириллицу — русский
# _re_cyrillic = re.compile(r'[а-яёА-ЯЁ]')


# def stem_text(s: str) -> str:
#     """Стемминг Snowball для русских и английских слов."""
#     words = s.split()
#     result = []
#     for w in words:
#         if _re_cyrillic.search(w):
#             result.append(_stemmer_ru.stem(w))
#         else:
#             result.append(_stemmer_en.stem(w))
#     return " ".join(result)


def preprocess_text(s: str) -> str:
    """Очистка текста: убирает markdown-разметку, URL, спецсимволы, lowercase + стемминг.
    Должна применяться одинаково при обучении и инференсе (в т.ч. в Dart)."""
    # Код-блоки (``` ... ```)
    s = re.sub(r"```[\s\S]*?```", " code ", s)
    # Инлайн-код (`...`)
    s = re.sub(r"`[^`\n]+`", " code ", s)
    # URL
    s = re.sub(r"https?://\S+", " url ", s)
    # Markdown-заголовки (### Title → Title)
    s = re.sub(r"^#+\s+", "", s, flags=re.MULTILINE)
    # Markdown-ссылки [text](url) → text
    s = re.sub(r"\[([^\]]+)\]\([^\)]+\)", r"\1", s)
    # Bold/italic (**text** / *text* / __text__)
    s = re.sub(r"[*_]{1,2}([^*_\n]+)[*_]{1,2}", r"\1", s)
    # Markdown цитаты (> text)
    s = re.sub(
        r"^\s*>\s*", "", s, flags=re.MULTILINE
    )  # Markdown-чекбоксы (- [ ] / - [x]) → токен listitem
    s = re.sub(
        r"^\s*-\s*\[[x ]\]\s*", "listitem ", s, flags=re.MULTILINE | re.IGNORECASE
    )
    # Нумерованные списки (1. / 2.) → токен listitem
    s = re.sub(r"(?:^|\n)\s*\d+\.\s+", "\nlistitem ", s, flags=re.MULTILINE)
    # Bullet-списки (- / * / •) → токен listitem
    s = re.sub(
        r"(?:^|\n)\s*[-*•]\s+", "\nlistitem ", s, flags=re.MULTILINE
    )  # Нижний регистр
    s = s.lower()
    # Оставляем только буквы, цифры и пробелы
    s = re.sub(r"[^\w\s]", " ", s)
    # Схлопываем пробелы
    s = re.sub(r"\s+", " ", s).strip()
    # Стемминг
    # s = stem_text(s)
    return s


def load_train_data(json_path: str, class_names: list[str] | None = None):
    """Загружает данные из JSON и строит маппинг классов.

    Если class_names передан — использует его (для eval-датасета, чтобы индексы
    совпадали с обучающим маппингом). Иначе строит маппинг из файла.
    Записи с классом, не входящим в class_names, пропускаются.
    """
    with open(json_path, encoding="utf-8") as f:
        raw = json.load(f)

    def split_classes(s: str) -> list[str]:
        return [c.lower() for c in re.split(r"[\s,\.;:]+", s) if c]

    if class_names is None:
        keys = set()
        for item in raw:
            keys.update(split_classes(item["class"]))
        class_names = sorted(keys)

    class_to_idx = {cls: idx for idx, cls in enumerate(class_names)}

    train_data = [
        (preprocess_text(item["text"]), class_to_idx[split_classes(item["class"])[0]])
        for item in raw
        if split_classes(item["class"])[0] in class_to_idx
    ]

    # counts = Counter([x["class"] for x in raw])
    # col_w = max(len(c) for c in counts) + 2
    # print(f"\n{'Class':<{col_w}} {'Count':>6}  {'Bar'}")
    # print("-" * (col_w + 30))
    # for cls, cnt in sorted(counts.items(), key=lambda x: -x[1]):
    #     bar = "█" * (cnt // 5)
    #     print(f"{cls:<{col_w}} {cnt:>6}  {bar}")
    # print(f"{'Total':<{col_w}} {sum(counts.values()):>6}\n")

    return train_data, class_names

def print_class_distribution(
    train_data: list[tuple[str, int]], class_names: list[str] | None = None
):
    """Печатает распределение классов для train_data вида (text, label_idx)."""
    if not train_data:
        print("\nClass  Count  Bar\n----------------\nTotal      0\n")
        return

    label_counts = Counter(label for _, label in train_data)

    if class_names is not None:
        counts = {class_names[idx]: cnt for idx, cnt in sorted(label_counts.items())}
    else:
        counts = {str(idx): cnt for idx, cnt in sorted(label_counts.items())}

    col_w = max(len(c) for c in counts) + 2
    print(f"\n{'Class':<{col_w}} {'Count':>6}  {'Bar'}")
    print("-" * (col_w + 30))
    for cls, cnt in sorted(counts.items(), key=lambda x: -x[1]):
        bar = "█" * (cnt // 10)
        print(f"{cls:<{col_w}} {cnt:>6}  {bar}")
    print(f"{'Total':<{col_w}} {sum(counts.values()):>6}\n")