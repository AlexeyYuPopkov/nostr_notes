import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/tools/list_item_position.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/presentation/widgets/brand_avatar.dart';
import 'package:nostr_notes/l10n/localization.dart';


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
        onTap: onTap == null ? null : () => onTap?.call(item),
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
                  BrandAvatar(
                    side: _avatarSize,
                    title: item.title,
                    website: item.websiteUrl,
                    isLocked: isLocked,
                  ),
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
