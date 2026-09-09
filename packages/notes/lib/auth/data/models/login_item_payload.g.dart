// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_item_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginItemPayload _$LoginItemPayloadFromJson(Map<String, dynamic> json) =>
    LoginItemPayload(
      v: (json['v'] as num).toInt(),
      title: json['title'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      url: json['url'] as String,
      notes: json['notes'] as String,
      rev: (json['rev'] as num).toInt(),
      updatedAt: (json['updated_at'] as num?)?.toInt(),
      image: json['image'] as String?,
      totp: json['totp'] as String?,
    );

Map<String, dynamic> _$LoginItemPayloadToJson(LoginItemPayload instance) =>
    <String, dynamic>{
      'v': instance.v,
      'title': instance.title,
      'username': instance.username,
      'password': instance.password,
      'url': instance.url,
      'notes': instance.notes,
      'updated_at': ?instance.updatedAt,
      'image': ?instance.image,
      'totp': ?instance.totp,
      'rev': instance.rev,
    };
