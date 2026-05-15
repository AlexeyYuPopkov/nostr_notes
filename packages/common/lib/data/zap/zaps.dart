import 'dart:convert';
import 'package:nostr/key_tool/bech32_tool.dart';
import 'zapper.dart';

/// {@template zap_utils}
/// A utility class for zaps.
/// {@endtemplate}
class ZapUtils {
  /// {@macro zap_utils}
  static String? deriveLnUrl(String address) {
    if (address.startsWith('lnurl1')) {
      return address;
    }

    // url
    if (address.contains('://')) {
      final url = address;

      final bytes = utf8.encode(url);

      final result = Bech32Tool.encodeBech32FromBytes(
        'lnurl',
        bytes,
        maxLength: 200,
      );

      return result;
    }

    // lud16 address
    if (address.contains('@')) {
      final split = address.split('@');

      if (split.length == 2) {
        final [name, domain] = split;

        final url = 'https://$domain/.well-known/lnurlp/$name';

        final bytes = utf8.encode(url);

        final result = Bech32Tool.encodeBech32FromBytes(
          'lnurl',
          bytes,
          maxLength: 300,
        );

        return result;
      }
    }
    return null;
  }

  /// Fetches the zapper for the given user data.
  static Future<UserDataZapper?> fetchUserZapper(String lnurl) async {
    if (lnurl.isEmpty) {
      return null;
    }

    return UserDataZapper.tryGet(lnurl);
  }

  static Future<UserDataZapper?> fetchUserZapperFromRawString(
    String maybeLightningAddress,
  ) async {
    final lnurl = deriveLnUrl(maybeLightningAddress);

    if (lnurl == null) {
      return null;
    }

    final zapper = await UserDataZapper.tryGet(lnurl);

    return zapper;
  }

  // static Future<UserDataZapper?> fetchCommunityZapper(
  //   Community community,
  // ) async {
  //   final lnurl = communityLnUrl(community);

  //   if (lnurl == null) {
  //     return null;
  //   }

  //   return UserDataZapper.tryGet(lnurl);
  // }

  static String? userLnUrl(String? lud06, String? lud16) {
    final lud06Lower = lud06?.toLowerCase() ?? '';
    final lud16Lower = lud16?.toLowerCase() ?? '';

    if (lud06Lower.isEmpty && lud16Lower.isEmpty) {
      return null;
    }

    final lightningAddress = (lud06 ?? lud16 ?? '').trim();
    final lnurl = deriveLnUrl(lightningAddress);
    return lnurl;
  }
}
