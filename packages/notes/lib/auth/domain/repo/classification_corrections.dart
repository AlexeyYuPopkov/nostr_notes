import 'dart:math' as math;

final class ClassificationCorrections {
  const ClassificationCorrections();

  // ─── Security ────────────────────────────────────────────────────────────

  static final _securityPatterns = [
    RegExp(r'nsec1[a-z0-9]{50,}', caseSensitive: false),
    RegExp(r'npub1[a-z0-9]{50,}', caseSensitive: false),
    RegExp(r'[0-9a-f]{64}', caseSensitive: false),
    RegExp(r'[0-9a-f]{32}', caseSensitive: false),
    RegExp(r'[A-Za-z0-9+/]{40,}={0,2}', caseSensitive: false),
    RegExp(r'[A-Z0-9]{5,}:[A-Za-z0-9_\-]{35,}', caseSensitive: false),
    RegExp(
      r'(?:password|passwd|pwd|secret|token|api_key)\s*[=:]\s*\S+',
      caseSensitive: false,
    ),
    RegExp(r'(?:DATABASE_URL|SECRET_KEY|JWT_SECRET)\s*=', caseSensitive: false),
  ];

  double shannonEntropy(String text) {
    if (text.isEmpty) return 0.0;
    final counts = <int, int>{};
    for (final c in text.codeUnits) {
      counts[c] = (counts[c] ?? 0) + 1;
    }
    final total = text.length;
    return -counts.values.fold(0.0, (sum, count) {
      final p = count / total;
      return sum + p * math.log(p) / math.ln2;
    });
  }

  double _maxTokenEntropy(String text) {
    const r = r'[\s\n`"]+';
    final tokens = text.split(RegExp(r));
    double maxH = 0.0;
    for (final token in tokens) {
      if (token.length < 8) continue;
      final h = shannonEntropy(token);
      if (h > maxH) maxH = h;
    }
    return maxH;
  }

  double _specialCharDensity(String text) {
    const special = r'#@!*&^~|\\';
    final count = text.codeUnits
        .where((c) => special.codeUnits.contains(c))
        .length;
    return count / math.max(text.length, 1);
  }

  bool _matchesSecurityPattern(String text) {
    for (final pattern in _securityPatterns) {
      if (pattern.hasMatch(text)) return true;
    }
    return false;
  }

  double securityScore(String text) {
    double s = 0.0;

    if (_matchesSecurityPattern(text)) s += 0.6;

    final maxH = _maxTokenEntropy(text);
    if (maxH > 3.8) {
      s += 0.5;
    } else if (maxH > 3.2) {
      s += 0.2;
    }

    if (_specialCharDensity(text) > 0.1) s += 0.2;

    return math.min(s, 1.0);
  }

  // ─── Journal / Bookmarks ─────────────────────────────────────────────────

  static final _markdownListItem = RegExp(r'^\s*[-*+]\s+\S', multiLine: true);
  static final _urlPattern = RegExp(
    r'https?://[^\s\)\]"]+',
    caseSensitive: false,
  );

  /// Число строк-элементов markdown-списка.
  int _listItemCount(String text) => _markdownListItem.allMatches(text).length;

  int _urlCount(String text) => _urlPattern.allMatches(text).length;

  /// Score для journal: несколько пунктов markdown-списка.
  double journalScore(String text) {
    final count = _listItemCount(text);
    if (count >= 4) return 0.7;
    if (count >= 2) return 0.4;
    return 0.0;
  }

  /// Score для bookmarks: только ссылки.
  double bookmarksScore(String text) {
    final urls = _urlCount(text);
    if (urls >= 3) return 0.7;
    if (urls >= 1) return 0.4;
    return 0.0;
  }

  // ─── Finance ─────────────────────────────────────────────────────────────

  static final _financePattern = RegExp(
    r'[€£¥₽₴₩₺₹₿]'
    r'|\b(?:usd|eur|gbp|rub|btc|eth|bnb|sol|xrp|ada|doge|dot|avax|matic|'
    r'ltc|link|xlm|atom|uni|trx|etc|bch|algo|near|icp|vet|fil|egld|'
    r'bitcoin|ethereum|binance|solana|ripple|cardano|dogecoin|polkadot|'
    r'avalanche|polygon|litecoin|chainlink|stellar|cosmos|uniswap|tron|'
    r'tether|usdt|usdc|dai|stablecoin|defi|nft|altcoin|memecoin|'
    r'crypto|currency|coin|token|wallet|exchange|blockchain|'
    r'invoice|salary|budget|expense|profit|revenue|income|'
    r'stock|share|bond|dividend|portfolio|invest|'
    r'bank|payment|transaction|loan|mortgage|tax|'
    r'balance|credit|debit|cash)\b',
    caseSensitive: false,
  );

  double financeScore(String text) {
    final count = _financePattern.allMatches(text).length;
    if (count >= 4) return 0.7;
    if (count >= 2) return 0.4;
    if (count >= 1) return 0.2;
    return 0.0;
  }

  // ─── Work ────────────────────────────────────────────────────────────────

  static final _workPattern = RegExp(
    r'\b(?:api|sdk|cli|git|commit|push|pull\s*request|merge|branch|'
    r'deploy|deployment|ci[/\s]?cd|pipeline|docker|kubernetes|k8s|'
    r'hotfix|release|sprint|jira|'
    r'backend|frontend|database|sql|endpoint|'
    r'refactor|exception|'
    r'module|library|framework|dependency|'
    r'bug|issue|'
    r'bash|cron|nginx|aws|gcp|azure)\b',
    caseSensitive: false,
  );

  double workScore(String text) {
    final count = _workPattern.allMatches(text).length;
    if (count >= 4) return 0.7;
    if (count >= 2) return 0.4;
    if (count >= 1) return 0.2;
    return 0.0;
  }
}
