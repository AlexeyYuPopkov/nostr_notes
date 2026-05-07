import 'package:equatable/equatable.dart';

abstract class BaseLabel extends Equatable {
  final String textValue;

  const BaseLabel({required this.textValue});

  @override
  List<Object?> get props => [textValue];
}

final class EncryptedLabel extends BaseLabel {
  const EncryptedLabel({required super.textValue});

  @override
  List<Object?> get props => [textValue];
}

final class Label extends BaseLabel {
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

  @override
  String get textValue => type.toStringValue();

  Label._({required this.type, required this.symbol})
    : super(textValue: type.toStringValue());

  factory Label.from(String? name) {
    if (name == null || name.isEmpty) {
      return Label._(type: .other, symbol: other);
    }

    final type = CategoryType.fromString(name);
    final symbol = Label.categorySymbols[type.name] ?? other;
    return Label._(type: type, symbol: symbol);
  }

  factory Label.fromCategoryType(CategoryType type) {
    final symbol = Label.categorySymbols[type.name] ?? other;
    return Label._(type: type, symbol: symbol);
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

  static const valuesList = [
    finance,
    journal,
    personal,
    security,
    travel,
    work,
    bookmarks,
  ];

  static const categorySymbols = {
    'finance': '💰',
    'journal': '📝',
    'personal': '🙂',
    'security': '🔐',
    'travel': '🌍',
    'work': '🛠',
    'bookmarks': '🔖',
  };

  String get symbol => Label.categorySymbols[name] ?? Label.other;

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
