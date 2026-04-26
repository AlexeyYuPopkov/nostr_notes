# import re
# import math
# from collections import Counter

# def shannon_entropy(text: str) -> float:
#     """Энтропия Шеннона в битах на символ."""
#     if not text:
#         return 0.0
#     counts = Counter(text)
#     total = len(text)
#     return -sum((c / total) * math.log2(c / total) for c in counts.values())

# def max_token_entropy(text: str) -> tuple[float, str]:
#     """
#     Ищет токен (слово/строку) с максимальной энтропией.
#     Возвращает (max_entropy, token).
#     """
#     # Разбиваем по пробелам, переносам, кавычкам, тикам
#     tokens = re.split(r'[\s\n`\'"]+', text)
#     best = (0.0, "")
#     for token in tokens:
#         if len(token) < 8:  # слишком короткие — пропускаем
#             continue
#         h = shannon_entropy(token)
#         if h > best[0]:
#             best = (h, token)
#     return best

# # Паттерны для известных форматов
# SECURITY_PATTERNS = [
#     r'\bnsec1[a-z0-9]{50,}\b',           # Nostr private key
#     r'\bnpub1[a-z0-9]{50,}\b',           # Nostr public key
#     r'\bxprv[a-zA-Z0-9]{100,}\b',        # BIP32 extended private key
#     r'\b[0-9a-f]{64}\b',                  # hex 256-bit (SHA256, private key)
#     r'\b[0-9a-f]{32}\b',                  # hex 128-bit
#     r'[A-Za-z0-9+/]{40,}={0,2}',         # base64 длинная строка
#     r'[A-Z0-9]{5,}:[A-Za-z0-9_\-]{35,}', # Telegram bot token формат
#     r'(?:password|passwd|pwd|secret|token|api_key)\s*[=:]\s*\S+',  # key=value
#     r'(?:DATABASE_URL|SECRET_KEY|JWT_SECRET)\s*=',
# ]

# def special_char_density(text: str) -> float:
#     """Плотность спецсимволов: $#@!*&^"""
#     special = sum(1 for c in text if c in r'$#@!*&^~|\\')
#     return special / max(len(text), 1)

# def security_score(text: str) -> float:
#     """
#     Возвращает score от 0 до 1: насколько текст похож на Security-контент.
#     """
#     score = 0.0

#     # 1. Проверка известных паттернов
#     for pattern in SECURITY_PATTERNS:
#         if re.search(pattern, text, re.IGNORECASE):
#             score += 0.6
#             break

#     # 2. Максимальная энтропия токена
#     max_h, token = max_token_entropy(text)
#     if max_h > 3.2: # 3.8: # очень высокая — явно пароль/ключ
#         score += 0.6
#     elif max_h > 2.9: # 3.4: # высокая
#         score += 0.3

#     # 3. Плотность спецсимволов
#     density = special_char_density(text)
#     if density > 0.1:  # >10% спецсимволов
#         score += 0.2

#     return min(score, 1.0)