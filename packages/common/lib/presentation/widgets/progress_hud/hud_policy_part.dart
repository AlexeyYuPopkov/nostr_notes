part of 'progress_hud.dart';

abstract class HudPolicy {
  const factory HudPolicy.defaultValue() = IndicatorWithCheckmark;
  factory HudPolicy.indicator({String? hint}) => Indicator(hint: hint ?? '');
  factory HudPolicy.blocking() = Blocking;
  const HudPolicy();
  Widget build(BuildContext context, ProgressHudVm vm);
}

final class Blocking extends HudPolicy {
  const Blocking();

  @override
  Widget build(BuildContext context, ProgressHudVm vm) =>
      const SizedBox.expand();
}

final class Indicator extends HudPolicy {
  const Indicator({this.hint = ''});
  final String hint;

  @override
  Widget build(BuildContext context, ProgressHudVm vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.indent2x),
        child: RepaintBoundary(
          child: Container(
            height: 110.0,
            width: 110.0,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(Sizes.padding2x),
            ),
            clipBehavior: Clip.hardEdge,
            child: Material(
              // Unstyled Material paints an opaque theme canvasColor
              // background (near-black in dark mode), hiding the
              // translucent white Container above and the hint text
              // painted on top of it — must stay transparent.
              color: Colors.transparent,
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: Sizes.defaultRowHeight,
                      height: Sizes.defaultRowHeight,
                      child: CircularProgressIndicator(value: vm.progress),
                    ),
                  ),
                  if (hint.isNotEmpty)
                    Positioned(
                      bottom: Sizes.indent,
                      left: Sizes.indent,
                      right: Sizes.indent,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          hint,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: TextSizes.error,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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

final class IndicatorWithCheckmark extends HudPolicy {
  static const hudSize = Size(110.0, 110.0);
  static const checkmarkThreshold = 0.9;
  static const animationDuration = Duration(milliseconds: 500);

  const IndicatorWithCheckmark({this.hint = ''});
  final String hint;

  @override
  Widget build(BuildContext context, ProgressHudVm vm) {
    return IndicatorWithCheckmarkContent(hint: hint, vm: vm);
  }
}

final class IndicatorWithCheckmarkContent extends StatefulWidget {
  final String hint;
  final ProgressHudVm vm;

  const IndicatorWithCheckmarkContent({
    super.key,
    required this.hint,
    required this.vm,
  });

  @override
  State<IndicatorWithCheckmarkContent> createState() =>
      _IndicatorWithCheckmarkContentState();
}

final class _IndicatorWithCheckmarkContentState
    extends State<IndicatorWithCheckmarkContent> {
  late final vm = widget.vm;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.indent2x),
        child: RepaintBoundary(
          child: Container(
            height: IndicatorWithCheckmark.hudSize.height,
            width: IndicatorWithCheckmark.hudSize.width,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(Sizes.padding2x),
            ),
            clipBehavior: Clip.hardEdge,
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  AnimatedCrossFade(
                    duration: IndicatorWithCheckmark.animationDuration,
                    crossFadeState:
                        (vm.progress ?? 0.0) <
                            IndicatorWithCheckmark.checkmarkThreshold
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Center(
                      child: SizedBox(
                        width: Sizes.defaultRowHeight,
                        height: Sizes.defaultRowHeight,
                        child: CircularProgressIndicator(value: vm.progress),
                      ),
                    ),
                    secondChild: const Center(child: CheckmarkAnimation()),
                  ),
                  if (widget.hint.isNotEmpty)
                    Positioned(
                      bottom: Sizes.indent,
                      left: Sizes.indent,
                      right: Sizes.indent,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.hint,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: TextSizes.error,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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

final class CheckmarkAnimation extends StatefulWidget {
  const CheckmarkAnimation({super.key});

  @override
  State<CheckmarkAnimation> createState() => _CheckmarkAnimationState();
}

final class _CheckmarkAnimationState extends State<CheckmarkAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: IndicatorWithCheckmark.animationDuration,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circleColor =
        Theme.of(context).extension<SuccessColors>()?.success ?? Colors.green;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return CustomPaint(
          size: IndicatorWithCheckmark.hudSize / 2.0,
          painter: CheckmarkPainter(
            progress: _animation.value,
            circleColor: circleColor,
          ),
        );
      },
    );
  }
}

final class CheckmarkPainter extends CustomPainter {
  final Color circleColor;
  final double progress;

  CheckmarkPainter({required this.progress, required this.circleColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final radius = size.width / 2.0;

    // --- Круг ---
    final circlePaint = Paint()
      ..color = circleColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * progress.clamp(0.0, 1.0), circlePaint);

    if (progress > 0.5) {
      final checkProgress = ((progress - 0.5) * 2).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.08
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // Точки галочки (относительно центра)
      final start = Offset(center.dx - radius * 0.35, center.dy);
      final mid = Offset(center.dx - radius * 0.05, center.dy + radius * 0.3);
      final end = Offset(center.dx + radius * 0.4, center.dy - radius * 0.25);

      final path = Path();
      path.moveTo(start.dx, start.dy);

      // Первый отрезок: start → mid
      final firstSegLen = 0.4; // 40% прогресса на первый отрезок
      if (checkProgress < firstSegLen) {
        final t = checkProgress / firstSegLen;
        final p = Offset.lerp(start, mid, t)!;
        path.lineTo(p.dx, p.dy);
      } else {
        path.lineTo(mid.dx, mid.dy);
        // Второй отрезок: mid → end
        final t = ((checkProgress - firstSegLen) / (1.0 - firstSegLen)).clamp(
          0.0,
          1.0,
        );
        final p = Offset.lerp(mid, end, t)!;
        path.lineTo(p.dx, p.dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CheckmarkPainter old) => old.progress != progress;
}
