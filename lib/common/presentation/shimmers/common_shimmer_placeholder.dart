import 'package:flutter/material.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/app/theme/shimmer_colors.dart';
import 'package:shimmer/shimmer.dart';
// import 'package:tribly/theme/sizes.dart';
// import 'package:tribly/theme/theme_extensions/shimmer_colors.dart';

final class CommonShimmerPlaceholder extends StatelessWidget {
  final Size size;
  final BorderRadiusGeometry borderRadius;

  const CommonShimmerPlaceholder({
    super.key,
    required this.size,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(Sizes.radiusSmall),
    ),
  });

  @override
  Widget build(BuildContext context) => CommonShimmer(
        borderRadius: borderRadius,
        child: SizedBox(
          width: size.width,
          height: size.height,
        ),
      );
}

final class CommonShimmer extends StatelessWidget {
  final Widget child;
  final bool isActive;

  final BorderRadiusGeometry borderRadius;

  const CommonShimmer({
    super.key,
    required this.child,
    this.isActive = true,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(Sizes.radiusSmall),
    ),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shimmerColors = theme.extension<ShimmerColors>()!;
    return isActive
        ? ClipRRect(
            borderRadius: borderRadius,
            child: Shimmer.fromColors(
              baseColor: shimmerColors.baseColor,
              highlightColor: shimmerColors.highlightColor,
              child: ColoredBox(
                color: shimmerColors.decorationColor,
                child: child,
              ),
            ),
          )
        : child;
  }
}

final class ShimmerAvatar extends StatelessWidget {
  final double avatarSize;

  const ShimmerAvatar({
    super.key,
    required this.avatarSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shimmerColors = theme.extension<ShimmerColors>()!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(avatarSize / 2),
      child: Shimmer.fromColors(
        baseColor: shimmerColors.baseColor,
        highlightColor: shimmerColors.highlightColor,
        child: ColoredBox(
          color: shimmerColors.decorationColor,
          child: SizedBox(
            width: avatarSize,
            height: avatarSize,
          ),
        ),
      ),
    );
  }
}

class ShimmerText extends StatelessWidget {
  final bool isLoading;
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final ShimmerColors? colors;

  const ShimmerText(
    this.text, {
    super.key,
    required this.isLoading,
    TextStyle? style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.colors,
  }) : style = style ?? const TextStyle();

  double get _placeholderHeight {
    const heightFactor = 0.9;
    return heightFactor * (style.fontSize ?? TextSizes.small);
  }

  TextStyle _style(BuildContext context) {
    return isLoading
        ? style.copyWith(
            decoration: TextDecoration.lineThrough,
            decorationColor: Theme.of(context).primaryColor,
            decorationThickness: _placeholderHeight,
            color: Colors.transparent,
          )
        : style;
  }

  @override
  Widget build(BuildContext context) {
    return CommonShimmer(
      isActive: isLoading,
      // colors: colors,
      child: Text(
        text,
        textAlign: isLoading ? TextAlign.justify : textAlign,
        style: _style(context),
        overflow: overflow,
        maxLines: maxLines,
      ),
    );
  }
}

// final class CommonShimmer extends StatelessWidget {
//   final Widget child;
//   final bool isActive;
//   final double? borderRadiusValue;

//   const CommonShimmer({
//     super.key,
//     required this.child,
//     this.isActive = true,
//     this.borderRadiusValue,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final shimmerColors = theme.extension<ShimmerColors>()!;

//     return isActive
//         ? ClipRRect(
//             borderRadius: BorderRadius.circular(
//               borderRadiusValue ?? Sizes.radiusSmall,
//             ),
//             child: Shimmer.fromColors(
//               baseColor: shimmerColors.baseColor,
//               highlightColor: shimmerColors.highlightColor,
//               child: ColoredBox(
//                 color: shimmerColors.decorationColor,
//                 child: child,
//               ),
//             ),
//           )
//         : child;
//   }
// }
