import 'dart:async';

import 'package:chat/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A read-only key with a copy button that shows a check mark for a moment.
final class CopyableKeyField extends StatefulWidget {
  final String label;
  final String value;
  final String copyButtonSemanticsId;

  const CopyableKeyField({
    super.key,
    required this.label,
    required this.value,
    required this.copyButtonSemanticsId,
  });

  @override
  State<CopyableKeyField> createState() => _CopyableKeyFieldState();
}

final class _CopyableKeyFieldState extends State<CopyableKeyField> {
  static const _copiedMarkDuration = Duration(seconds: 2);

  bool _copied = false;
  Timer? _copiedMarkTimer;

  @override
  void dispose() {
    _copiedMarkTimer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    if (!mounted) {
      return;
    }
    _copiedMarkTimer?.cancel();
    setState(() => _copied = true);
    _copiedMarkTimer = Timer(_copiedMarkDuration, () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      key: ValueKey(widget.value),
      initialValue: widget.value,
      readOnly: true,
      maxLines: 1,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: Semantics(
          identifier: widget.copyButtonSemanticsId,
          child: Tooltip(
            message: context.l10n.profileCopyTooltip,
            child: CupertinoButton(
              minimumSize: Size.zero,
              padding: const EdgeInsets.all(Sizes.indent),
              onPressed: () => unawaited(_copy()),
              child: Icon(
                _copied ? Icons.check : Icons.copy,
                color: colorScheme.primary,
                size: Sizes.padding2x,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
