import 'dart:convert';

import 'package:equatable/equatable.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:nostr/key_tool/bech32_tool.dart';
import 'package:nostr_notes/services/hex_to_bytes.dart';

@JsonSerializable()
final class UserDataZapper extends Equatable {
  /// {@macro user_data_zapper}
  const UserDataZapper({
    required this.callback,
    required this.maxSendable,
    required this.minSendable,
    required this.metadata,
    required this.tag,
    required this.allowsNostr,
    required this.nostrPubkey,
    required this.originalLnurl,
  });

  /// Creates a [UserDataZapper] from the given [map].
  factory UserDataZapper.fromMap(
    Map<String, dynamic> map, {
    required String originalLnurl,
  }) {
    return UserDataZapper(
      callback: map['callback'] as String?,
      maxSendable: map['maxSendable'] as num?,
      minSendable: map['minSendable'] as num?,
      // maybe decode it here, or decode it on demand?
      metadata: map['metadata'] as String?,
      tag: map['tag'] as String?,
      allowsNostr: map['allowsNostr'] as bool?,
      nostrPubkey: map['nostrPubkey'] as String?,
      originalLnurl: originalLnurl,
    );
  }

  /// The callback url of the zapper.
  ///   @JsonKey(name: "'")
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

  /// The original lnurl of the zapper.
  final String originalLnurl;

  /// Tries to get the user data zapper from the given [lnurl].
  static Future<UserDataZapper?> tryGet(String lnurl) async {
    try {
      final decodeLnrl = Bech32Tool.decodeBech32(lnurl);

      final data = decodeLnrl[0];

      final url = utf8.decode(HexToBytes.hexToBytes(data));
      final uri = Uri.parse(url);

      final res = await http.get(uri);
      final body = res.body;

      if (body.canBeParsedToJson()) {
        final parsed = jsonDecode(body) as Map<String, dynamic>;

        if (parsed.containsKey('callback')) {
          return UserDataZapper.fromMap(parsed, originalLnurl: lnurl);
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
    callback,
    maxSendable,
    minSendable,
    metadata,
    tag,
  ];
}

extension on String {
  bool canBeParsedToJson() {
    try {
      jsonDecode(this) as Map<String, dynamic>;
      return true;
    } catch (e) {
      return false;
    }
  }
}
