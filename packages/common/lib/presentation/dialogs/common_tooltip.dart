import 'package:flutter/material.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/dialogs/opacity_button.dart';

final class CommonTooltip extends StatelessWidget {
  static const showDuration = Duration(seconds: 10);
  final String title;
  final String message;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  const CommonTooltip({
    super.key,
    required this.title,
    required this.message,
    this.padding = const EdgeInsets.all(Sizes.indent),
    this.margin = const EdgeInsets.symmetric(horizontal: Sizes.indent4x),
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const maxWidth = 400.0;
    final theme = Theme.of(context);
    return OpacityButton(
      onTap: onTap,
      child: Tooltip(
        padding: padding,
        margin: margin,
        constraints: const BoxConstraints(maxWidth: maxWidth),
        richMessage: TextSpan(
          text: title.isEmpty ? null : title,
          style: theme.textTheme.titleSmall?.copyWith(height: 2.0),
          children: message.isEmpty
              ? null
              : [
                  TextSpan(
                    text: title.isEmpty ? message : '\n$message',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.all(Radius.circular(Sizes.radius)),
          border: Border.all(
            color: theme.colorScheme.outline,
            width: Sizes.thickness,
          ),
        ),
        showDuration: showDuration,
        textStyle: theme.textTheme.bodyMedium,
        triggerMode: TooltipTriggerMode.tap,
        child: child,
      ),
    );
  }
}
