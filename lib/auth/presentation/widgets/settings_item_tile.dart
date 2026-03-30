import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/common/presentation/tools/list_item_position.dart';

final class SettingsItemTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Color? titleTextColor;
  final String sectionTitle;
  final ListItemPosition position;
  final VoidCallback? onTap;

  const SettingsItemTile({
    super.key,
    required this.title,
    this.subtitle = '',
    this.trailing,
    this.titleTextColor,
    this.sectionTitle = '',
    required this.position,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final insets = switch (position) {
      .first => const EdgeInsets.only(top: Sizes.halfIndent),
      .last => const EdgeInsets.only(bottom: Sizes.halfIndent),
      .single => const EdgeInsets.symmetric(vertical: Sizes.halfIndent),
      .middle => EdgeInsets.zero,
    };

    final showSectionTitle = switch (position) {
      .first => true,
      .single => true,
      .middle => false,
      .last => false,
    };

    return Column(
      children: [
        if (showSectionTitle && sectionTitle.isNotEmpty)
          _SectionTitle(sectionTitle: sectionTitle),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.indent2x),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,

              borderRadius: position.getRadius(),
              border: position.getBorder(
                theme.colorScheme.outline,
                thickness: Sizes.thicknessHalf,
              ),
            ),
            child: Column(
              children: [
                CupertinoButton(
                  foregroundColor:
                      titleTextColor ?? theme.colorScheme.onSurface,
                  padding: const EdgeInsets.all(Sizes.indent2x) + insets,
                  minimumSize: .zero,
                  onPressed: onTap,
                  child: _ButtonContent(
                    title: title,
                    subtitle: subtitle,
                    trailing: trailing,
                  ),
                ),
                if (position.needsSeparator())
                  Divider(
                    indent: Sizes.indent2x,
                    endIndent: Sizes.indent2x,
                    height: Sizes.thicknessHalf,
                    thickness: Sizes.thicknessHalf,
                    color: theme.colorScheme.outline,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final class _ButtonContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _ButtonContent({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return subtitle.isEmpty
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(title), ?trailing],
          )
        : _ButtonContentWithSubtitle(
            title: title,
            subtitle: subtitle,
            trailing: trailing,
          );
  }
}

final class _ButtonContentWithSubtitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _ButtonContentWithSubtitle({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(title), ?trailing],
        ),
        const SizedBox(height: Sizes.halfIndent),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

final class _SectionTitle extends StatelessWidget {
  final String sectionTitle;
  const _SectionTitle({required this.sectionTitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Sizes.indent2x,
        Sizes.indent2x,
        Sizes.indent2x,
        Sizes.indent,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(sectionTitle, style: theme.textTheme.titleMedium),
      ),
    );
  }
}
