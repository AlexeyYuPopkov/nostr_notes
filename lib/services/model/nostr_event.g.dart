// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nostr_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NostrEvent _$NostrEventFromJson(Map<String, dynamic> json) => NostrEvent(
      kind: (json['kind'] as num?)?.toInt() ?? 999999,
      id: json['id'] as String? ?? '',
      pubkey: json['pubkey'] as String? ?? '',
      createdAt: (json['created_at'] as num?)?.toInt() ?? 0,
      tags: (json['tags'] as List<dynamic>?)
              ?.map(
                  (e) => (e as List<dynamic>).map((e) => e as String).toList())
              .toList() ??
          [],
      content: json['content'] as String? ?? '',
      sig: json['sig'] as String? ?? '',
    );

Map<String, dynamic> _$NostrEventToJson(NostrEvent instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'id': instance.id,
      'pubkey': instance.pubkey,
      'created_at': instance.createdAt,
      'tags': instance.tags,
      'content': instance.content,
      'sig': instance.sig,
    };
