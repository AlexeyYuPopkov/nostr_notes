import 'tag_value.dart';

abstract class BaseTag {
  const BaseTag();
  String get value;
  String get sharp => '#$value';

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BaseTag) return false;
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}

enum Tag implements BaseTag {
  e(TagValue.e),
  d(TagValue.d),
  p(TagValue.p),
  a(TagValue.a),
  b(TagValue.b),
  k(TagValue.k),
  t(TagValue.t),
  g(TagValue.g),
  client(TagValue.client);

  @override
  final String value;
  const Tag(this.value);

  @override
  String get sharp => '#$value';
}

final class SummaryTag extends BaseTag {
  const SummaryTag();
  @override
  String get value => 'summary';
}
