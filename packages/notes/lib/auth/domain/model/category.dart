import 'package:equatable/equatable.dart';

final class Category extends Equatable {
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

  final CategoryType type;
  final String symbol;

  const Category._({required this.type, required this.symbol});

  factory Category.from(String? name) {
    if (name == null || name.isEmpty) {
      return const Category._(type: .other, symbol: other);
    }

    final type = CategoryType.fromString(name);
    final symbol = Category.categorySymbols[type.name] ?? other;
    return Category._(type: type, symbol: symbol);
  }

  factory Category.fromCategoryType(CategoryType type) {
    final symbol = Category.categorySymbols[type.name] ?? other;
    return Category._(type: type, symbol: symbol);
  }

  @override
  List<Object?> get props => [type, symbol];
}

enum CategoryType {
  finance,
  journal,
  personal,
  security,
  travel,
  work,
  bookmarks,
  other;

  static const categorySymbols = {
    'finance': '💰',
    'journal': '📝',
    'personal': '🙂',
    'security': '🔐',
    'travel': '🌍',
    'work': '🛠',
    'bookmarks': '🔖',
  };

  String get symbol => Category.categorySymbols[name] ?? Category.other;

  static CategoryType fromString(String? name) {
    if (name == null || name.isEmpty) {
      return CategoryType.other;
    }

    return CategoryType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => CategoryType.other,
    );
  }

  String toStringValue() => name;
}
