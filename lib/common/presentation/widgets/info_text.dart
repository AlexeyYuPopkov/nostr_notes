import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/common/presentation/dialogs/common_tooltip.dart';

final class InfoText extends StatelessWidget {
  final String text;

  const InfoText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.indent2x,
        vertical: Sizes.indent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonTooltip(
            message: text,
            title: context.l10n.commonAttention,
            child: CupertinoButton(
              minimumSize: .zero,
              padding: .zero,
              onPressed: () {},
              child: Icon(
                Icons.info_outline,
                size: Sizes.iconSmall,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: Sizes.indent),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
