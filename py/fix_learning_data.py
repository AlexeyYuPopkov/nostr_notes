"""
Script to review and fix class labels in learning.json and learning_metric_data.json
based on regex patterns for each class, and add new classes: Bookmarks, Journal.
"""

import json
import re
import sys
from pathlib import Path

# ─────────────────────────── Patterns ───────────────────────────

SECURITY_PATTERNS = [
    re.compile(r'nsec1[a-z0-9]{10,}', re.IGNORECASE),
    re.compile(r'npub1[a-z0-9]{10,}', re.IGNORECASE),
    re.compile(r'\b[0-9a-f]{64}\b', re.IGNORECASE),
    re.compile(r'\b[0-9a-f]{32}\b', re.IGNORECASE),
    re.compile(r'[A-Za-z0-9+/]{40,}={0,2}'),
    re.compile(r'[A-Z0-9]{5,}:[A-Za-z0-9_\-]{10,}'),
    re.compile(r'(?:password|passwd|pwd|secret|token|api[_\s]?key)\s*[=:]\s*\S+', re.IGNORECASE),
    re.compile(r'(?:DATABASE_URL|SECRET_KEY|JWT_SECRET|STRIPE_KEY|PRIVATE_KEY)\s*=', re.IGNORECASE),
    re.compile(r'ghp_[A-Za-z0-9]{20,}'),
    re.compile(r'sk_live_[A-Za-z0-9]+'),
    re.compile(r'AKIA[A-Z0-9]{16}'),
    re.compile(r'\b(?:seed\s*phrase|recovery\s*phrase|private\s*key|encryption|2fa|bitwarden|firewall|audit\s*ssh|rotate.*api\s*key|disk\s*encryption|password\s*manager|backup.*seed|seed.*backup|unauthorized\s*login|security\s*incident|security\s*checklist|security\s*incident)\b', re.IGNORECASE),
    re.compile(r'\b(?:шифрование|приватный\s*ключ|seed[- ]фраза|двухфакторн|менеджер\s*паролей|бэкап.*seed|обновить\s*пароли|резервн.*копи)\b', re.IGNORECASE),
]

FINANCE_PATTERNS = [
    re.compile(r'[€£¥₽₴₩₺₹₿]'),
    re.compile(r'\$\s*\d'),
    re.compile(r'\b\d[\d\s]*(?:₽|руб\.?|rub)\b', re.IGNORECASE),
    re.compile(
        r'\b(?:usd|eur|gbp|rub|btc|eth|usdt|usdc|defi|nft|crypto|bitcoin|ethereum|'
        r'invoice|salary|budget|expense|profit|revenue|income|'
        r'stock|share|bond|dividend|portfolio|invest|'
        r'bank|payment|transaction|loan|mortgage|tax|'
        r'balance|credit|debit|cash|rent\s*payment|transfer\s*rent|'
        r'savings|subscription|finance)\b',
        re.IGNORECASE,
    ),
    re.compile(
        r'\b(?:зарплата|бюджет|расходы|доходы|расход|платёж|платеж|оплатить|заплатить|'
        r'аренда|ипотека|кредит|налог|баланс|счёт|счет|инвестиц|накопления|вклад|'
        r'банк|ИИС|ОФЗ|брокер|дивиденд|квитанция|комунальн|коммунальн|пени|тариф)\b',
        re.IGNORECASE,
    ),
]

WORK_PATTERNS = [
    re.compile(
        r'\b(?:api|sdk|cli|git|commit|push|pull\s*request|merge|branch|'
        r'deploy|deployment|ci[/\s]?cd|pipeline|docker|kubernetes|k8s|'
        r'hotfix|release|sprint|jira|trello|'
        r'backend|frontend|database|sql|endpoint|'
        r'refactor|exception|'
        r'module|library|framework|dependency|'
        r'bug|issue|'
        r'bash|cron|nginx|aws|gcp|azure|server|staging|production|'
        r'flutter|swiftui|swift|kotlin|react|node|python|typescript|javascript|dart|'
        r'unit\s*test|pull\s*request|code\s*review|standup|sprint|retro|'
        r'onboarding|figma|mockup|ui|ux)\b',
        re.IGNORECASE,
    ),
    re.compile(
        r'\b(?:баг|деплой|релиз|бэкенд|фронтенд|рефакторинг|пулл[- ]реквест|'
        r'авторизация|логин|токен|сервер|тест|документация|стендап|спринт)\b',
        re.IGNORECASE,
    ),
]

TRAVEL_PATTERNS = [
    re.compile(
        r'\b(?:airport|flight|hotel|hostel|booking|ticket|visa|passport|'
        r'trip|travel|journey|itinerary|train|bus\s*station|railway|'
        r'check[- ]in|check[- ]out|luggage|suitcase|backpack|'
        r'tokyo|kyoto|osaka|lisbon|porto|berlin|rome|florence|venice|prague|'
        r'bangkok|phuket|istanbul|tbilisi|barcelona|'
        r'shinkansen|airbnb|rent\s*a\s*car)\b',
        re.IGNORECASE,
    ),
    re.compile(
        r'\b(?:аэропорт|вокзал|билет|отель|хостел|бронировать|забронировать|виза|паспорт|'
        r'поездка|путешествие|маршрут|чемодан|рейс|страховка|'
        r'тбилиси|батуми|казбеги|прага|берлин|рим|барселона|'
        r'санкт[- ]петербург|калининград|сочи|карели|грузи)\b',
        re.IGNORECASE,
    ),
]

BOOKMARKS_PATTERNS = [
    re.compile(r'https?://\S+'),
]

JOURNAL_PATTERNS = [
    # Numbered list (e.g. "1. ...\n2. ...")
    re.compile(r'(?:^|\n)\s*\d+\.\s+\S', re.MULTILINE),
    # Bullet list lines (markdown -, *, •)
    re.compile(r'(?:^|\n)\s*[-*•]\s+\S', re.MULTILINE),
    # Markdown checkbox
    re.compile(r'- \[[ x]\]'),
    # Day headers suggesting journal
    re.compile(r'(?:^|\n)##?\s*(?:сегодня|завтра|понедельник|вторник|среда|четверг|пятница|суббота|воскресенье|today|tomorrow|monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b', re.IGNORECASE | re.MULTILINE),
    # Date-like patterns
    re.compile(r'\b(?:утром|вечером|ночью|днём|this\s+morning|this\s+evening|last\s+night|woke\s+up|went\s+to\s+bed|лёг\s+спать|проснулся|встал\s+в\s+\d)\b', re.IGNORECASE),
]

PERSONAL_KEYWORDS = re.compile(
    r'\b(?:купить|покупк|магазин|продукт|еда|готовить|приготовить|ужин|обед|завтрак|рецепт|'
    r'позвонить|звонок|мама|папа|семья|друг|брат|сестра|жена|муж|родители|'
    r'здоровье|врач|стоматолог|таблетк|витамин|анализ|аптека|тренировка|спортзал|зал|йога|'
    r'прогулка|парк|собак|кот|животн|'
    r'день\s*рождения|праздник|подарок|'
    r'уборка|убраться|пылесос|стирк|'
    r'buy|groceries|milk|eggs|food|cook|dinner|lunch|breakfast|recipe|'
    r'call\s+(?:mom|dad|parents)|family|friend|'
    r'doctor|dentist|pharmacy|medicine|vitamin|workout|gym|yoga|run|'
    r'dog|cat|pet|'
    r'birthday|gift|present|'
    r'clean|vacuum|laundry)\b',
    re.IGNORECASE,
)


def matches_any(text: str, patterns: list) -> bool:
    return any(p.search(text) for p in patterns)


def count_list_items(text: str) -> int:
    items = re.findall(r'(?:^|\n)\s*(?:\d+\.|[-*•])\s+\S', text, re.MULTILINE)
    return len(items)


def is_project_idea(text: str) -> bool:
    """Returns True if the text is primarily an app/project idea (not a real secret/credential)."""
    return bool(re.search(
        r'\b(?:idea|app\s*idea|pet\s*project|concept|идея|приложение|проект)\b',
        text, re.IGNORECASE
    ))


def has_real_credentials(text: str) -> bool:
    """Returns True only if text contains actual credential patterns, not just security-topic words."""
    credential_patterns = [
        re.compile(r'nsec1[a-z0-9]{10,}', re.IGNORECASE),
        re.compile(r'npub1[a-z0-9]{10,}', re.IGNORECASE),
        re.compile(r'\b[0-9a-f]{64}\b', re.IGNORECASE),
        re.compile(r'(?:password|passwd|pwd|secret|token|api[_\s]?key)\s*[=:]\s*\S+', re.IGNORECASE),
        re.compile(r'(?:DATABASE_URL|SECRET_KEY|JWT_SECRET|STRIPE_KEY)\s*=', re.IGNORECASE),
        re.compile(r'ghp_[A-Za-z0-9]{20,}'),
        re.compile(r'sk_live_[A-Za-z0-9]+'),
        re.compile(r'AKIA[A-Z0-9]{16}'),
        re.compile(r'witch\s+collapse|abandon\s+abandon'),  # seed phrases
        re.compile(r'(?:login|passw(?:ord)?)\s*:\s*\S+', re.IGNORECASE),  # Login: xxx / Passw: xxx
        re.compile(r'\b(?:supervisor|teampassword|dev_st)\b.*\d{4,}', re.IGNORECASE | re.DOTALL),
    ]
    return any(p.search(text) for p in credential_patterns)


def has_security_topic_words(text: str) -> bool:
    """Returns True if text is about security as a topic (checklist, advice, etc.)."""
    return bool(re.search(
        r'\b(?:2fa|firewall|audit\s*ssh|rotate.*api\s*key|disk\s*encryption|'
        r'password\s*manager|bitwarden|unauthorized\s*login|security\s*incident|'
        r'security\s*checklist|security\s*incident|'
        r'шифрование|двухфакторн|менеджер\s*паролей|обновить\s*пароли|'
        r'резервн.*копи|seed[- ]фраза|приватный\s*ключ|vpn\s+на\s+публичн)\b',
        text, re.IGNORECASE
    ))


def classify(text: str, original_class: str) -> str:
    """Determine the best class for a note based on its content."""

    # Security — only if actual credentials are present, OR security-topic text
    if has_real_credentials(text):
        return "Security"
    if has_security_topic_words(text) and not is_project_idea(text):
        return "Security"

    # Bookmarks — mostly URLs (check early to avoid URL-heavy text being misclassified)
    url_count = len(re.findall(r'https?://\S+', text))
    non_url_text = re.sub(r'https?://\S+', '', text).strip()
    # If URL-dominant, classify as Bookmarks (unless also has strong work tech keywords in non-url text)
    if url_count >= 1 and len(non_url_text) < 200:
        # If non-url part has meaningful work content, keep as Work
        if matches_any(non_url_text, WORK_PATTERNS) and len(non_url_text) > 30:
            return "Work"
        return "Bookmarks"

    # Work — check before Finance to avoid "expense tracker idea" going to Finance
    if is_project_idea(text) and matches_any(text, WORK_PATTERNS):
        return "Work"
    if is_project_idea(text):
        return "Work"

    # Finance — strong numeric/currency signals (skip if it's a project/retrospective context)
    is_retrospective = bool(re.search(
        r'\b(?:retrospective|retro|post[- ]mortem|lessons\s*learned)\b', text, re.IGNORECASE
    ))
    if matches_any(text, FINANCE_PATTERNS) and not is_retrospective:
        return "Finance"

    # Travel — location & transport signals
    if matches_any(text, TRAVEL_PATTERNS):
        return "Travel"

    # Work — tech keywords
    if matches_any(text, WORK_PATTERNS):
        return "Work"

    # Journal — list-heavy personal diary style (multiple items + day/time references)
    list_items = count_list_items(text)
    has_day_header = bool(re.search(
        r'(?:^|\n)##?\s*(?:сегодня|завтра|понедельник|вторник|среда|четверг|пятница|'
        r'суббота|воскресенье|today|tomorrow|monday|tuesday|wednesday|thursday|friday|'
        r'saturday|sunday)\b', text, re.IGNORECASE | re.MULTILINE
    ))
    has_time_ref = bool(re.search(
        r'\b(?:утром|вечером|ночью|днём|this\s+morning|this\s+evening|woke\s+up|'
        r'went\s+to\s+bed|лёг\s+спать|проснулся|встал\s+в\s+\d|'
        r'got\s+up|had\s+(?:coffee|dinner|lunch)|ordered\s+pizza)\b', text, re.IGNORECASE
    ))
    if list_items >= 3 and (has_day_header or has_time_ref):
        # but NOT if it's a work log / tech journal
        has_tech_content = matches_any(text, WORK_PATTERNS)
        if not has_tech_content:
            return "Journal"

    # Personal — everyday life keywords
    if PERSONAL_KEYWORDS.search(text):
        return "Personal"

    # Fall back to original
    return original_class


def process_file(path: str) -> None:
    file = Path(path)
    data = json.loads(file.read_text(encoding='utf-8'))

    changes = 0
    class_counts: dict[str, int] = {}

    for item in data:
        original = item['class']
        new_class = classify(item['text'], original)
        item['class'] = new_class
        class_counts[new_class] = class_counts.get(new_class, 0) + 1
        if new_class != original:
            changes += 1
            print(f"  CHANGED: [{original}] → [{new_class}]")
            print(f"    {item['text'][:80].strip()!r}")

    file.write_text(json.dumps(data, ensure_ascii=False, indent=4), encoding='utf-8')

    print(f"\n✓ {file.name}: {changes} items reclassified")
    print("  Distribution:", dict(sorted(class_counts.items())))


if __name__ == '__main__':
    base = Path(__file__).parent
    files = [
        base / 'learning.json',
        base / 'learning_metric_data.json',
    ]
    for f in files:
        print(f"\n{'='*60}")
        print(f"Processing: {f.name}")
        print('='*60)
        process_file(str(f))
