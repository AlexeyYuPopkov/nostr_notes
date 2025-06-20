import 'tag_value.dart';

abstract class BaseTag {
  const BaseTag();
  String get name;

  String get sharpedName => '#$name';
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
  final String name;
  const Tag(this.name);

  @override
  String get sharpedName => '#$name';
}
