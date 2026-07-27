import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/tools/list_item_position.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/l10n/localization.dart';

/// A single account row: colored rounded-square avatar with the item's
/// initial, title and username, plus a trailing chevron. Undecryptable items
/// render locked (a lock icon and a "locked" label) instead of leaking blanks.
final class AccountListCard extends StatelessWidget {
  static const double _avatarSize = 40;

  final LoginItem item;
  final ListItemPosition position;
  final ValueChanged<LoginItem>? onTap;

  const AccountListCard({
    super.key,
    required this.item,
    required this.position,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isLocked = item.error != null;

    final needsSeparator = position.needsSeparator();

    final title = isLocked
        ? l10n.notesListLockedNoteTitle
        : (item.title.trim().isEmpty ? l10n.accsTabTitle : item.title.trim());
    final subtitle = isLocked
        ? l10n.notesListLockedNoteSubtitle
        : item.username.trim();

    return Container(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.symmetric(horizontal: Sizes.indent),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: position.getRadius(),
        border: position.getBorder(
          theme.colorScheme.outline,
          thickness: Sizes.thicknessHalf,
        ),
      ),
      child: InkWell(
        borderRadius: position.getRadius(),
        onTap: onTap == null ? null : () => onTap!(item),
        child: Padding(
          padding: const EdgeInsets.only(
            left: Sizes.indent2x,
            top: Sizes.indent,
            right: Sizes.indent,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: needsSeparator
                  ? Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outline,
                        width: Sizes.thicknessHalf,
                      ),
                    )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: Sizes.indent),
              child: Row(
                children: [
                  _Avatar(item: item, isLocked: isLocked),
                  const SizedBox(width: Sizes.indent2x),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Sizes.indent),
                  Icon(
                    Icons.chevron_right,
                    size: Sizes.iconMedium,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _Avatar extends StatelessWidget {
  final LoginItem item;
  final bool isLocked;

  const _Avatar({required this.item, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLocked) {
      return Container(
        width: AccountListCard._avatarSize,
        height: AccountListCard._avatarSize,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(Sizes.radiusSmall),
        ),
        child: Icon(
          Icons.lock_outline,
          size: Sizes.iconMedium,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final seed = item.title.trim().isNotEmpty
        ? item.title.trim()
        : item.websiteUrl.trim();
    final initial = seed.isEmpty ? '?' : seed.characters.first.toUpperCase();

    return Container(
      width: AccountListCard._avatarSize,
      height: AccountListCard._avatarSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _avatarColor(seed),
        borderRadius: BorderRadius.circular(Sizes.radiusSmall),
      ),
      child: Text(
        initial,
        style: theme.textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Deterministic, readable avatar color derived from [seed].
Color _avatarColor(String seed) {
  final hue = (seed.hashCode % 360).abs().toDouble();
  return HSLColor.fromAHSL(1, hue, 0.55, 0.5).toColor();
}
