import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'zapper.g.dart';

@JsonSerializable()
final class UserDataZapper extends Equatable {
  /// {@macro user_data_zapper}
  const UserDataZapper({
    this.callback,
    this.maxSendable,
    this.minSendable,
    this.metadata,
    this.tag,
    this.allowsNostr,
    this.nostrPubkey,
    this.originalLnurl = '',
  });

  factory UserDataZapper.fromJson(Map<String, dynamic> json) =>
      _$UserDataZapperFromJson(json);

  /// Creates a [UserDataZapper] from the given [map] with an [originalLnurl].
  factory UserDataZapper.fromMap(
    Map<String, dynamic> map, {
    required String originalLnurl,
  }) {
    final zapper = UserDataZapper.fromJson(map);
    return UserDataZapper(
      callback: zapper.callback,
      maxSendable: zapper.maxSendable,
      minSendable: zapper.minSendable,
      metadata: zapper.metadata,
      tag: zapper.tag,
      allowsNostr: zapper.allowsNostr,
      nostrPubkey: zapper.nostrPubkey,
      originalLnurl: originalLnurl,
    );
  }

  /// The callback url of the zapper.
  final String? callback;

  /// The maximum amount that can be sent.
  final num? maxSendable;

  /// The minimum amount that can be sent.
  final num? minSendable;

  /// The metadata of the zapper.
  final String? metadata;

  /// The tag of the zapper.
  final String? tag;

  /// Whether the zapper allows nostr or not.
  final bool? allowsNostr;

  /// The nostr public key of the zapper.
  final String? nostrPubkey;

  /// The original lnurl of the zapper (not part of the JSON payload).
  @JsonKey(includeFromJson: false, includeToJson: true)
  final String originalLnurl;

  Map<String, dynamic> toJson() => _$UserDataZapperToJson(this);

  @override
  List<Object?> get props => [
    callback,
    maxSendable,
    minSendable,
    metadata,
    tag,
  ];
}
