final class OneToManyMap {
  final Map<String, Set<String>> _items = {};

  void add({
    required String key,
    required String value,
  }) {
    final values = _items[key] ?? {};
    values.add(value);
    _items[key] = values;
  }

  void addAll({
    required String key,
    required Iterable<String> values,
  }) {
    final items = _items[key] ?? {};
    items.addAll(values);
    _items[key] = items;
  }

  Set<String> get({required String key}) => _items[key] ?? {};

  Set<String>? removeKey({required String key}) => _items.remove(key);
  void removeValue({required String key, required String value}) =>
      _items[key]?.remove(value);
}
