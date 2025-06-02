import 'package:flutter/material.dart';

final class SliverSizedBox extends StatelessWidget {
  final double height;
  final double width;

  const SliverSizedBox({
    super.key,
    this.height = 0.0,
    this.width = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: height,
        width: width,
      ),
    );
  }
}
