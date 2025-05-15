// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nostr_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NostrFilter _$NostrFilterFromJson(Map<String, dynamic> json) => NostrFilter(
      kinds: (json['"kinds"'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      ids: (json['"ids"'] as List<dynamic>?)?.map((e) => e as String).toList(),
      authors: (json['"authors"'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      e: (json['"#e"'] as List<dynamic>?)?.map((e) => e as String).toList(),
      t: (json['"#t"'] as List<dynamic>?)?.map((e) => e as String).toList(),
      p: (json['"#p"'] as List<dynamic>?)?.map((e) => e as String).toList(),
      a: (json['"#a"'] as List<dynamic>?)?.map((e) => e as String).toList(),
      since: (json['"since"'] as num?)?.toInt(),
      until: (json['"until"'] as num?)?.toInt(),
      limit: (json['"limit"'] as num?)?.toInt(),
      search: json['"search"'] as String?,
      additional: json['"additional"'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$NostrFilterToJson(NostrFilter instance) =>
    <String, dynamic>{
      if (instance.kinds case final value?) '"kinds"': value,
      if (instance.ids case final value?) '"ids"': value,
      if (instance.authors case final value?) '"authors"': value,
      if (instance.e case final value?) '"#e"': value,
      if (instance.t case final value?) '"#t"': value,
      if (instance.p case final value?) '"#p"': value,
      if (instance.a case final value?) '"#a"': value,
      if (instance.since case final value?) '"since"': value,
      if (instance.until case final value?) '"until"': value,
      if (instance.limit case final value?) '"limit"': value,
      if (instance.search case final value?) '"search"': value,
      if (instance.additional case final value?) '"additional"': value,
    };
