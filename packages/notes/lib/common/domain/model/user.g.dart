// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  pubkey: json['pubkey'] as String,
  name: json['name'] as String?,
  displayName: json['display_name'] as String?,
  about: json['about'] as String?,
  picture: json['picture'] as String?,
  banner: json['banner'] as String?,
  website: json['website'] as String?,
  nip05: json['nip05'] as String?,
  lud16: json['lud16'] as String?,
  lud06: json['lud06'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'name': ?instance.name,
  'display_name': ?instance.displayName,
  'about': ?instance.about,
  'picture': ?instance.picture,
  'banner': ?instance.banner,
  'website': ?instance.website,
  'nip05': ?instance.nip05,
  'lud16': ?instance.lud16,
  'lud06': ?instance.lud06,
};
