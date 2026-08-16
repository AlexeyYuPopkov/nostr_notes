import 'package:flutter/material.dart';
import 'package:nostr_notes/app/icons/accs_icons.dart';

final class BrandAvatar extends StatelessWidget with BrandAvatarHelper {
  final double side;
  final String title;
  final String website;
  final bool isLocked;

  const BrandAvatar({
    super.key,
    required this.side,
    required this.title,
    required this.website,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLocked) {
      return Container(
        width: side,
        height: side,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(side / 3.0),
        ),
        child: Icon(
          Icons.lock_outline,
          size: side * 0.5,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final titleText = title.trim();
    final websiteText = website.trim();
    final seed = titleText.isNotEmpty ? titleText : websiteText;
    final icon = matchBrandIcon(website: websiteText, title: titleText);

    return Container(
      width: side,
      height: side,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: seed.isEmpty
            ? theme.colorScheme.primaryContainer
            : avatarColor(seed),
        borderRadius: BorderRadius.circular(side / 3.0),
      ),
      child: icon != null
          ? Icon(icon, size: side * 0.5, color: Colors.white)
          : Text(
              seed.isEmpty ? '?' : seed.characters.first.toUpperCase(),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: side * 0.4,
              ),
            ),
    );
  }
}

mixin BrandAvatarHelper {
  static final Map<String, IconData> _brandIconsByLowerSlug = {
    for (final entry in AccsIcons.bySlug.entries)
      entry.key.toLowerCase(): entry.value,
  };

  IconData? matchBrandIcon({required String website, required String title}) {
    final fromWebsite = _slugFromWebsite(website);
    if (fromWebsite != null) {
      final icon = _brandIconsByLowerSlug[fromWebsite];
      if (icon != null) {
        return icon;
      }
    }

    final fromTitle = _slugFromTitle(title);
    return fromTitle == null ? null : _brandIconsByLowerSlug[fromTitle];
  }

  String? _slugFromWebsite(String website) {
    if (website.isEmpty) {
      return null;
    }

    var host = website.toLowerCase().replaceFirst(
      RegExp(r'^[a-z][a-z0-9+.-]*://'),
      '',
    );

    host = host.split(RegExp(r'[/?#]')).first;

    final labels = host.split('.').where((label) => label.isNotEmpty).toList();
    if (labels.isNotEmpty && labels.first == 'www') {
      labels.removeAt(0);
    }
    if (labels.isEmpty) {
      return null;
    }

    return labels.length >= 2 ? labels[labels.length - 2] : labels.first;
  }

  String? _slugFromTitle(String title) {
    final normalized = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return normalized.isEmpty ? null : normalized;
  }

  Color avatarColor(String seed) {
    final hue = (seed.hashCode % 360).abs().toDouble();
    return HSLColor.fromAHSL(1, hue, 0.55, 0.5).toColor();
  }
}
