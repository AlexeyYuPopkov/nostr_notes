final class Category {
  static const other = '📁';
  static const categorySymbols = {
    'finance': '💰',
    'journal': '📝',
    'personal': '🙂',
    'security': '🔐',
    'travel': '🌍',
    'work': '🛠',
    'bookmarks': '🔖',
  };

  final String name;
  final String symbol;

  const Category({required this.name, required this.symbol});

  factory Category.from(String? name) {
    if (name == null || name.isEmpty) {
      return const Category(name: 'other', symbol: other);
    }

    final symbol = categorySymbols[name];
    if (symbol == null) {
      return const Category(name: 'other', symbol: other);
    }
    return Category(name: name, symbol: symbol);
  }
}
