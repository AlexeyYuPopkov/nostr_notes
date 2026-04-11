import 'package:common/app/theme/sizes.dart';
import 'package:common/l10n/localization.dart';
import 'package:common/presentation/widgets/markdown/gpt_markdown_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/xcode.dart';
import 'package:common/presentation/raw_event/raw_event_screen_vm.dart';
import 'package:common/presentation/raw_event/widgets/copy_button.dart';

final class RawEventScreenJson extends StatelessWidget {
  final RawEventScreenVm vm;
  const RawEventScreenJson({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const language = 'json';
    const jsonStyle = TextStyle(
      fontFamily: 'JetBrainsMono',
      package: 'gpt_markdown',
      fontSize: TextSizes.tiny,
    );
    return ValueListenableBuilder(
      valueListenable: vm.isJsonExpanded,
      builder: (context, expanded, _) {
        return Column(
          crossAxisAlignment: .start,
          spacing: Sizes.indent,

          children: [
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    onPressed: () => vm.toggleJsonExpanded(),
                    padding: EdgeInsets.zero,
                    minimumSize: .zero,
                    child: Row(
                      spacing: Sizes.indent,
                      children: [
                        Text(
                          context.commonL10n.rawEventScreenSectionTitleJson,
                          style: theme.textTheme.titleSmall,
                        ),
                        AnimatedRotation(
                          turns: expanded ? 0.25 : 0.0,
                          duration: AppDurations.medium,
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: Sizes.iconSmall,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CopyButton(vm: vm.copyJsonButtonVm),
                // CupertinoButton(
                //   onPressed: () => vm.copy(),
                //   padding: EdgeInsets.zero,
                //   minimumSize: .zero,
                //   child: ValueListenableBuilder(
                //     valueListenable: vm.isCopying,
                //     builder: (context, isCopying, child) {
                //       return AnimatedSwitcher(
                //         duration: AppDurations.medium,
                //         child: isCopying
                //             ? Icon(
                //                 Icons.check,
                //                 size: Sizes.iconSmall,
                //                 color: theme.colorScheme.primary,
                //               )
                //             : Icon(
                //                 Icons.copy,
                //                 size: Sizes.iconSmall,
                //                 color: theme.colorScheme.onSurface,
                //               ),
                //       );
                //     },
                //   ),
                // ),
              ],
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: expanded ? 1.0 : 0.0),
              duration: AppDurations.medium,
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return ClipRect(
                  child: Align(
                    heightFactor: value,
                    child: Opacity(opacity: value, child: child),
                  ),
                );
              },
              child: ValueListenableBuilder(
                valueListenable: vm.json,
                builder: (context, json, _) {
                  final md = '```$language\n$json\n```';
                  return GptMarkdownWidget(
                    md: md,
                    codeBuilder: (context, name, code, closed) {
                      const radius = BorderRadius.all(
                        Radius.circular(Sizes.radius),
                      );
                      return ClipRRect(
                        borderRadius: radius,
                        child: HighlightView(
                          code.trim(),
                          language: language,
                          theme: _highlightTheme(theme),
                          padding: const EdgeInsets.all(Sizes.indent),
                          textStyle: jsonStyle,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Map<String, TextStyle> _highlightTheme(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return isDark
        ? atomOneDarkTheme
        : {
            ...xcodeTheme,
            ...{
              'root': TextStyle(
                color: theme.colorScheme.onSurface,
                backgroundColor: theme.colorScheme.outlineVariant,
              ),
            },
          };
  }
}
