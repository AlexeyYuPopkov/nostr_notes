import 'package:flutter/material.dart';

final class SendFormButtonWrapper extends StatelessWidget {
  final bool isLoading;
  final bool isEnabled;
  final Widget child;
  final double? minWidth;

  const SendFormButtonWrapper({
    super.key,
    this.isLoading = false,
    this.isEnabled = true,
    required this.child,
    this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    const loaderIndicatorSize = 17.5;

    return SafeArea(
      top: false,
      right: false,
      left: false,
      child: AbsorbPointer(
        absorbing: !isEnabled || isLoading,
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: minWidth,
                child: Opacity(
                  opacity: isEnabled ? 1 : 0.5,
                  child: child,
                ),
              ),
            ),
            if (isLoading)
              const Positioned.fill(
                child: Center(
                  child: SizedBox(
                    height: loaderIndicatorSize,
                    width: loaderIndicatorSize,
                    child: RepaintBoundary(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
