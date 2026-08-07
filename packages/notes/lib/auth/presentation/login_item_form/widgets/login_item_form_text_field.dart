import 'dart:async';

import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/tools/list_item_position.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One row of the account form's grouped card: a small primary-colored label
/// above the value, an inset hairline divider towards the next row, and
/// trailing reveal/copy icons — styled after the reference design.
final class LoginItemFormTextField extends StatefulWidget {
  static const double _iconSize = 20.0;

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscurable;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final int? minLines;
  final int? maxLines;
  final bool enabled;
  final ListItemPosition position;

  const LoginItemFormTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.position,
    this.hint,
    this.obscurable = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.minLines,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<LoginItemFormTextField> createState() => _FormFieldState();
}

final class _FormFieldState extends State<LoginItemFormTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showCopy =
        !widget.enabled && widget.controller.text.trim().isNotEmpty;

    return Visibility(
      visible: widget.enabled || widget.controller.text.trim().isNotEmpty,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.indent2x),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiaryContainer,
          borderRadius: widget.position.getRadius(),
          border: widget.position.getBorder(
            theme.colorScheme.outline,
            thickness: Sizes.thicknessHalf,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: widget.position.needsSeparator()
                ? Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline,
                      width: Sizes.thicknessHalf,
                    ),
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Sizes.thicknessHalf),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    enabled: widget.enabled,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    textCapitalization: widget.textCapitalization,
                    minLines: widget.obscurable ? 1 : widget.minLines,
                    maxLines: widget.obscurable ? 1 : widget.maxLines,
                    obscureText: widget.obscurable && _obscured,
                    autocorrect: !widget.obscurable,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: Sizes.indentVariant2x,
                      ),
                      labelText: widget.label,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      hintText: widget.hint,
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.obscurable || showCopy,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: Sizes.indentVariant2x,
                    children: [
                      if (widget.obscurable)
                        CupertinoButton(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              setState(() => _obscured = !_obscured),
                          child: Icon(
                            _obscured
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: LoginItemFormTextField._iconSize,
                          ),
                        ),
                      if (showCopy)
                        _CopyIconButton(controller: widget.controller),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _CopyIconButton extends StatefulWidget {
  final TextEditingController controller;
  const _CopyIconButton({required this.controller});

  @override
  State<_CopyIconButton> createState() => _CopyIconButtonState();
}

final class _CopyIconButtonState extends State<_CopyIconButton> {
  static const _feedbackDuration = Duration(seconds: 2);

  bool _copied = false;
  Timer? _copyTimer;

  @override
  void dispose() {
    _copyTimer?.cancel();
    super.dispose();
  }

  void _onTap() {
    Clipboard.setData(ClipboardData(text: widget.controller.text));
    _copyTimer?.cancel();
    setState(() => _copied = true);
    _copyTimer = Timer(_feedbackDuration, () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CupertinoButton(
      minimumSize: Size.zero,
      padding: EdgeInsets.zero,
      onPressed: _onTap,
      child: Icon(
        _copied ? Icons.check : Icons.copy_outlined,
        color: theme.colorScheme.onSurfaceVariant,
        size: LoginItemFormTextField._iconSize,
      ),
    );
  }
}
