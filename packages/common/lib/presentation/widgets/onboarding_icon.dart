import 'package:common/app/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

final class OnboardingIcon extends StatelessWidget {
  final String assetPath;
  final String? semanticsLabel;
  const OnboardingIcon._(this.assetPath, {super.key, this.semanticsLabel});

  const factory OnboardingIcon.asset(
    String assetPath, {
    Key? key,
    String? semanticsLabel,
  }) = OnboardingIcon._;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: Sizes.iconTitle,
      height: Sizes.iconTitle,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.all(
          Radius.circular(Sizes.iconTitle * 103 / 512),
        ),
      ),
      child: SvgPicture.asset(
        assetPath,
        width: Sizes.iconTitle,
        height: Sizes.iconTitle,
        colorMapper: _IcColorMapper(
          colors: {Colors.black: colorScheme.primary},
        ),
        semanticsLabel: semanticsLabel,
      ),
    );
  }
}

final class _IcColorMapper extends ColorMapper {
  final Map<Color, Color> colors;

  const _IcColorMapper({required this.colors});
  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    return colors[color] ?? color;
  }
}
