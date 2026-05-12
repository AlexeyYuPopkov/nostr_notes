import 'package:flutter/material.dart';
import 'package:common/app/theme/sizes.dart';

final class ResizeDivider extends StatefulWidget {
  final ValueChanged<double> onDrag;

  const ResizeDivider({super.key, required this.onDrag});

  @override
  State<ResizeDivider> createState() => _ResizeDividerState();
}

final class _ResizeDividerState extends State<ResizeDivider> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = _isDragging
        ? theme.colorScheme.primary
        : theme.colorScheme.outline;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) => widget.onDrag(details.delta.dx),
        onHorizontalDragStart: (details) {
          if (!_isDragging) {
            setState(() => _isDragging = true);
          }
        },
        onHorizontalDragEnd: (details) {
          if (_isDragging) {
            setState(() => _isDragging = false);
          }
        },
        child: Row(
          mainAxisSize: .min,
          children: [
            VerticalDivider(width: 1, thickness: 1, color: color),
            Icon(Icons.drag_indicator, size: Sizes.iconSmall, color: color),
          ],
        ),
      ),
    );
  }
}
