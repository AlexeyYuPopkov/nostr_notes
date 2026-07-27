import 'package:flutter/material.dart';
import 'package:common/app/theme/sizes.dart';

final class NotesListSectionHeader extends StatefulWidget {
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
  State<NotesListSectionHeader> createState() => _NotesListSectionHeaderState();
}

final class _NotesListSectionHeaderState extends State<NotesListSectionHeader> {
  void _scheduleCallback() {
    if (widget.onBuildSectionTitle == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.mounted) {
        widget.onBuildSectionTitle?.call(context);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _scheduleCallback();
  }

  @override
  void didUpdateWidget(NotesListSectionHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onBuildSectionTitle != widget.onBuildSectionTitle ||
        oldWidget.title != widget.title ||
        oldWidget.isFirst != widget.isFirst) {
      _scheduleCallback();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: Sizes.indent2x,
        right: Sizes.indent2x,
        top: widget.isFirst ? Sizes.indent2x : Sizes.indentVariant4x,
        bottom: Sizes.indent,
      ),
      child: Text(
        widget.title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
