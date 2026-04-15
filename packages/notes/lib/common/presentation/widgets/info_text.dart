import 'package:common/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/dialogs/common_tooltip.dart';

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
            title: context.commonL10n.commonAttention,
            message: text,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: Sizes.iconSmall + Sizes.indent,
                minHeight: Sizes.iconMedium,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.info_outline,
                  size: Sizes.iconSmall,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
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
