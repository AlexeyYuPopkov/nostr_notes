import 'dart:async';

import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/tools/list_item_position.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final Widget? trailing;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final Widget? bottom;

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
    this.trailing,
    this.inputFormatters,
    this.autofillHints,
    this.bottom,
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
      child: _Decoration(
        position: widget.position,
        bottom: widget.bottom,
        child: Row(
          spacing: Sizes.indent,
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
                // `autocorrect: false` alone is not enough on Android:
                // keyboard suggestions (and learning the typed secret)
                // are governed by this separate flag.
                enableSuggestions: !widget.obscurable,
                inputFormatters: widget.inputFormatters,
                autofillHints: widget.autofillHints,
                style: theme.textTheme.bodyLarge,
                decoration: _decoration(theme),
              ),
            ),
            Visibility(
              visible: widget.obscurable || showCopy,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Sizes.indentVariant2x,
                children: [
                  if (widget.trailing != null) widget.trailing!,
                  if (widget.obscurable)
                    CupertinoButton(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      onPressed: () => setState(() => _obscured = !_obscured),
                      child: Icon(
                        _obscured
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: LoginItemFormTextField._iconSize,
                      ),
                    ),
                  if (showCopy) _CopyIconButton(controller: widget.controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(ThemeData theme) {
    return InputDecoration(
      // The app-wide InputDecorationTheme defaults to
      // `filled: true` with the *page* background color —
      // without this override that paints under the text,
      // visibly different from this row's own
      // tertiaryContainer fill.
      filled: false,
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
    );
  }
}

final class _Decoration extends StatelessWidget {
  final ListItemPosition position;
  final Widget child;
  final Widget? bottom;
  const _Decoration({required this.position, required this.child, this.bottom});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.indent2x),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: position.getRadius(),
        border: position.getBorder(
          theme.colorScheme.outline,
          thickness: Sizes.thicknessHalf,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: position.needsSeparator()
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
          child: bottom == null
              ? child
              : Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: Sizes.indentVariant2x,
                      ),
                      child: child,
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: Sizes.indentVariant,
                      child: bottom!,
                    ),
                  ],
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
