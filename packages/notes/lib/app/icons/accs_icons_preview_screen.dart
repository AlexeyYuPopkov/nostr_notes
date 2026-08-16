import 'package:common/app/theme/sizes.dart';
import 'package:flutter/material.dart';

import 'accs_icons.dart';

final class AccsIconsPreviewScreen extends StatelessWidget {
  const AccsIconsPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = AccsIcons.bySlug.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      appBar: AppBar(title: Text('AccsIcons (${entries.length})')),
      body: GridView.builder(
        padding: const EdgeInsets.all(Sizes.indent),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: Sizes.indent,
          crossAxisSpacing: Sizes.indent,
          childAspectRatio: 0.85,
        ),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _IconTile(slug: entry.key, icon: entry.value);
        },
      ),
    );
  }
}

final class _IconTile extends StatelessWidget {
  final String slug;
  final IconData icon;

  const _IconTile({required this.slug, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Sizes.radiusSmall),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: Sizes.icon),
          const SizedBox(height: Sizes.halfIndent),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.halfIndent),
            child: Text(
              slug,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}
