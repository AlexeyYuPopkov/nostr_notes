import 'package:flutter/material.dart';

final class LeftDrawer extends StatefulWidget {
  final double drawerWidth;
  final Widget drawer;
  final Widget content;

  const LeftDrawer({
    super.key,
    required this.drawerWidth,
    required this.drawer,
    required this.content,
  });

  @override
  State<LeftDrawer> createState() => LeftDrawerState();
}

final class LeftDrawerState extends State<LeftDrawer>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  void open() => _controller.forward();

  void close() => _controller.reverse();

  void toggle() =>
      _controller.status == AnimationStatus.dismissed ? open() : close();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final shift = widget.drawerWidth * _controller.value;
        final isOpen = _controller.status != AnimationStatus.dismissed;

        return Stack(
          children: [
            Transform.translate(
              offset: Offset(shift, 0.0),
              child: AbsorbPointer(absorbing: isOpen, child: widget.content),
            ),
            if (isOpen)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: close,
                ),
              ),
            Positioned(
              left: shift - widget.drawerWidth,
              top: 0,
              bottom: 0,
              width: widget.drawerWidth,
              child: widget.drawer,
            ),
          ],
        );
      },
    );
  }
}
