// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackupPayload _$BackupPayloadFromJson(Map<String, dynamic> json) =>
    BackupPayload(
      version: (json['version'] as num).toInt(),
      encrypted: json['encrypted'] as bool,
      events: (json['events'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      salt: json['salt'] as String?,
      iterations: (json['iterations'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BackupPayloadToJson(BackupPayload instance) =>
    <String, dynamic>{
      'version': instance.version,
      'encrypted': instance.encrypted,
      'salt': ?instance.salt,
      'iterations': ?instance.iterations,
      'events': instance.events,
    };
