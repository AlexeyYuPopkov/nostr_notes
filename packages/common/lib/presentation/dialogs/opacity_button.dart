import 'package:flutter/widgets.dart';

final class OpacityButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final double pressedOpacity;

  const OpacityButton({
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 100),
    this.pressedOpacity = 0.4,
    super.key,
  });

  @override
  State<OpacityButton> createState() => _OpacityButtonState();
}

class _OpacityButtonState extends State<OpacityButton> {
  double _opacity = 1.0;

  void _setPressed(bool pressed) {
    setState(() {
      _opacity = pressed ? widget.pressedOpacity : 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: widget.duration,
        child: widget.child,
      ),
    );
  }
}
