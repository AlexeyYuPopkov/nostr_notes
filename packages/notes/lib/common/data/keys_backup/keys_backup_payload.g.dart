// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keys_backup_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeysBackupPayload _$KeysBackupPayloadFromJson(Map<String, dynamic> json) =>
    KeysBackupPayload(
      version: (json['version'] as num).toInt(),
      type: json['type'] as String,
      salt: json['salt'] as String,
      iterations: (json['iterations'] as num).toInt(),
      keys: (json['keys'] as List<dynamic>)
          .map((e) => KeysBackupRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      exportedAt: json['exported_at'] as String?,
    );

Map<String, dynamic> _$KeysBackupPayloadToJson(KeysBackupPayload instance) =>
    <String, dynamic>{
      'version': instance.version,
      'type': instance.type,
      'exported_at': ?instance.exportedAt,
      'salt': instance.salt,
      'iterations': instance.iterations,
      'keys': instance.keys.map((e) => e.toJson()).toList(),
    };

KeysBackupRecord _$KeysBackupRecordFromJson(Map<String, dynamic> json) =>
    KeysBackupRecord(
      npub: json['npub'] as String,
      nsec: json['nsec'] as String,
      label: json['label'] as String?,
    );

Map<String, dynamic> _$KeysBackupRecordToJson(KeysBackupRecord instance) =>
    <String, dynamic>{
      'npub': instance.npub,
      'label': ?instance.label,
      'nsec': instance.nsec,
    };
