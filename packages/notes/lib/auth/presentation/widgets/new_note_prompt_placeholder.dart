import 'package:flutter/material.dart';
import 'package:nostr_notes/app/icons/app_icons.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:nostr_notes/common/presentation/layout/layout_config.dart';

final class NewNotePromptPlaceholder extends StatelessWidget {
  static const double opacity = 0.4;
  const NewNotePromptPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool isTablet = width >= LayoutConfig.desktopScreenWidth;
        final double iconRatio = isTablet ? 0.1 : 0.2;
        final double iconSize = width * iconRatio;
        final TextStyle textStyle = isTablet
            ? theme.textTheme.headlineLarge!.copyWith(
                fontWeight: FontWeight.w400,
              )
            : theme.textTheme.headlineLarge!;
        return Opacity(
          opacity: opacity,
          child: Padding(
            padding: const EdgeInsets.all(Sizes.indent4x),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: Sizes.indent2x,
                children: [
                  Image.asset(
                    AppIcons.splash,
                    width: iconSize,
                    height: iconSize,
                  ),
                  Text(
                    context.l10n.homeScreenEmptyStatePlaceholder,
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
