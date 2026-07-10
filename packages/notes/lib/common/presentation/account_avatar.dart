import 'package:flutter/material.dart';

final class AccountAvatar extends StatelessWidget {
  final String pubkey;
  final double size;

  const AccountAvatar({super.key, required this.pubkey, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorForPubkey(pubkey),
        shape: BoxShape.circle,
      ),
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
