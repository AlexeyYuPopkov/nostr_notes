import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

final class AccountAvatar extends StatelessWidget {
  final String pubkey;
  final double size;
  final String? pictureUrl;

  const AccountAvatar({
    super.key,
    required this.pubkey,
    required this.size,
    this.pictureUrl,
  });

  @override
  Widget build(BuildContext context) {
    final url = pictureUrl ?? '';

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: colorForPubkey(pubkey),
      foregroundImage: url.isEmpty ? null : CachedNetworkImageProvider(url),
      onForegroundImageError: url.isEmpty ? null : (_, _) {},
      child: Text(
        _initialsForPubkey(pubkey),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

Color colorForPubkey(String pubkey) {
  final hue = (pubkey.hashCode % 360).abs().toDouble();
  return HSLColor.fromAHSL(1, hue, 0.55, 0.5).toColor();
}

String _initialsForPubkey(String pubkey) {
  return pubkey.length >= 2 ? pubkey.substring(0, 2).toUpperCase() : '??';
}

String truncatePubkey(String pubkey) {
  if (pubkey.length <= 16) return pubkey;
  return '${pubkey.substring(0, 8)}…${pubkey.substring(pubkey.length - 6)}';
}
