import 'package:common/app/theme/app_theme_style.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:flutter/material.dart';

final class ThemeStyleIcon extends StatelessWidget {
  final AppThemePalette palette;

  const ThemeStyleIcon({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    const size = Sizes.indentVariant4x;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _StyleSwatchPainter(palette: palette)),
    );
  }
}

/// Paints a style's background as a circle with a primary-colored dot
/// inset bottom-right — the same preview [_StyleTile] used to render via a
/// `Stack` of two `Container`s, just as a single paint pass.
final class _StyleSwatchPainter extends CustomPainter {
  final AppThemePalette palette;

  const _StyleSwatchPainter({required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final outerRadius = size.shortestSide / 2;
    final outerCenter = size.center(Offset.zero);

    canvas.drawCircle(
      outerCenter,
      outerRadius,
      Paint()..color = palette.background,
    );
    canvas.drawCircle(
      outerCenter,
      outerRadius - Sizes.thickness / 2,
      Paint()
        ..color = palette.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = Sizes.thickness,
    );

    final dotRadius = outerRadius / 2;
    final dotCenter = outerCenter + Offset(dotRadius, dotRadius);

    // Background-colored ring separates the dot from the outer circle,
    // mirroring the old widget's `Border.all(color: palette.background)`.
    canvas.drawCircle(
      dotCenter,
      dotRadius + 1.5,
      Paint()..color = palette.background,
    );
    canvas.drawCircle(dotCenter, dotRadius, Paint()..color = palette.primary);
  }

  @override
  bool shouldRepaint(covariant _StyleSwatchPainter oldDelegate) {
    final old = oldDelegate.palette;
    return old.background != palette.background ||
        old.outline != palette.outline ||
        old.primary != palette.primary;
  }
}