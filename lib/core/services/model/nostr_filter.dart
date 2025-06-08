import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'nostr_filter.g.dart';

@immutable
@JsonSerializable(includeIfNull: false, explicitToJson: true)
final class NostrFilter {
  @JsonKey(name: '"kinds"', defaultValue: null)
  final List<int>? kinds;
  @JsonKey(name: '"ids"', defaultValue: null)
  final List<String>? ids;
  @JsonKey(name: '"authors"', defaultValue: null)
  final List<String>? authors;
  @JsonKey(name: '"#e"', defaultValue: null)
  final List<String>? e;
  @JsonKey(name: '"#t"', defaultValue: null)
  final List<String>? t;
  @JsonKey(name: '"#p"', defaultValue: null)
  final List<String>? p;
  @JsonKey(name: '"#a"', defaultValue: null)
  final List<String>? a;
  @JsonKey(name: '"since"', defaultValue: null)
  final int? since;
  @JsonKey(name: '"until"', defaultValue: null)
  final int? until;
  @JsonKey(name: '"limit"', defaultValue: null)
  final int? limit;
  @JsonKey(name: '"search"', defaultValue: null)
  final String? search;
  @JsonKey(name: '"additional"', defaultValue: null)
  final Map<String, dynamic>? additional;

  const NostrFilter({
    this.kinds,
    this.ids,
    this.authors,
    this.e,
    this.t,
    this.p,
    this.a,
    this.since,
    this.until,
    this.limit,
    this.search,
    this.additional,
  });

  factory NostrFilter.fromJson(Map<String, dynamic> json) =>
      _$NostrFilterFromJson(json);

  Map<String, dynamic> toJson() => _$NostrFilterToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NostrFilter) return false;
    return kinds == other.kinds &&
        ids == other.ids &&
        authors == other.authors &&
        e == other.e &&
        t == other.t &&
        p == other.p &&
        a == other.a &&
        since == other.since &&
        until == other.until &&
        limit == other.limit &&
        search == other.search;
  }

  @override
  int get hashCode => Object.hash(
        kinds,
        ids,
        authors,
        e,
        t,
        p,
        a,
        since,
        until,
        limit,
        search,
      );
}
