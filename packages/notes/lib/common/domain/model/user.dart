import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// User profile model based on NIP-01 (Kind 0: Metadata) and NIP-24 conventions.
/// https://github.com/nostr-protocol/nips/blob/master/01.md#kinds
/// https://github.com/nostr-protocol/nips/blob/master/24.md#kind-0
@JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake)
final class User extends Equatable {
  @JsonKey(includeToJson: false)
  final String pubkey;
  final String? name;
  final String? displayName;
  final String? about;
  final String? picture;
  final String? banner;
  final String? website;
  final String? nip05;
  final String? lud16;
  final String? lud06;

  const User({
    required this.pubkey,
    this.name,
    this.displayName,
    this.about,
    this.picture,
    this.banner,
    this.website,
    this.nip05,
    this.lud16,
    this.lud06,
  });

  factory User.fromJson({
    required String pubkey,
    required Map<String, dynamic> json,
  }) => _$UserFromJson({...json, 'pubkey': pubkey});

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [
    pubkey,
    name,
    displayName,
    about,
    picture,
    banner,
    website,
    nip05,
    lud16,
    lud06,
  ];
}
