import 'package:flutter/material.dart';
import 'package:common/app/theme/sizes.dart';

final class NotesListSectionHeader extends StatelessWidget {
  final String title;
  final bool isFirst;
  final void Function(BuildContext)? onBuildSectionTitle;

  const NotesListSectionHeader({
    super.key,
    required this.title,
    this.isFirst = false,
    this.onBuildSectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (onBuildSectionTitle != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => onBuildSectionTitle?.call(context),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: Sizes.indent2x,
        right: Sizes.indent2x,
        top: isFirst ? Sizes.indent2x : Sizes.indentVariant4x,
        bottom: Sizes.indent,
      ),
      child: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
