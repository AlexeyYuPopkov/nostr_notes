import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart'
    show ImageRenderMethodForWeb;
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
    final placeholder = CircleAvatar(
      radius: size / 2,
      backgroundColor: colorForPubkey(pubkey),
      child: Text(
        _initialsForPubkey(pubkey),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (url.isEmpty) return placeholder;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          placeholder,
          ClipOval(
            child: Image(
              image: CachedNetworkImageProvider(
                url,
                // HtmlImage hands CanvasKit an <img> texture that can paint
                // black; HttpGet decodes the bytes or fails to the placeholder.
                imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
              ),
              fit: BoxFit.cover,
              frameBuilder: (_, image, frame, _) =>
                  frame == null ? const SizedBox.shrink() : image,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ],
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
