// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nostr_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NostrFilter _$NostrFilterFromJson(Map<String, dynamic> json) => NostrFilter(
  kinds: (json['kinds'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  ids: (json['ids'] as List<dynamic>?)?.map((e) => e as String).toList(),
  authors: (json['authors'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  e: (json['#e'] as List<dynamic>?)?.map((e) => e as String).toList(),
  t: (json['#t'] as List<dynamic>?)?.map((e) => e as String).toList(),
  p: (json['#p'] as List<dynamic>?)?.map((e) => e as String).toList(),
  d: (json['#d'] as List<dynamic>?)?.map((e) => e as String).toList(),
  a: (json['#a'] as List<dynamic>?)?.map((e) => e as String).toList(),
  since: (json['since'] as num?)?.toInt(),
  until: (json['until'] as num?)?.toInt(),
  limit: (json['limit'] as num?)?.toInt(),
  search: json['search'] as String?,
  additional: json['additional'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$NostrFilterToJson(NostrFilter instance) =>
    <String, dynamic>{
      'kinds': ?instance.kinds,
      'ids': ?instance.ids,
      'authors': ?instance.authors,
      '#e': ?instance.e,
      '#t': ?instance.t,
      '#p': ?instance.p,
      '#d': ?instance.d,
      '#a': ?instance.a,
      'since': ?instance.since,
      'until': ?instance.until,
      'limit': ?instance.limit,
      'search': ?instance.search,
      'additional': ?instance.additional,
    };
