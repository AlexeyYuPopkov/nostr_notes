// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDataZapper _$UserDataZapperFromJson(Map<String, dynamic> json) =>
    UserDataZapper(
      callback: json['callback'] as String?,
      maxSendable: json['maxSendable'] as num?,
      minSendable: json['minSendable'] as num?,
      metadata: json['metadata'] as String?,
      tag: json['tag'] as String?,
      allowsNostr: json['allowsNostr'] as bool?,
      nostrPubkey: json['nostrPubkey'] as String?,
    );

Map<String, dynamic> _$UserDataZapperToJson(UserDataZapper instance) =>
    <String, dynamic>{
      'callback': instance.callback,
      'maxSendable': instance.maxSendable,
      'minSendable': instance.minSendable,
      'metadata': instance.metadata,
      'tag': instance.tag,
      'allowsNostr': instance.allowsNostr,
      'nostrPubkey': instance.nostrPubkey,
      'originalLnurl': instance.originalLnurl,
    };
