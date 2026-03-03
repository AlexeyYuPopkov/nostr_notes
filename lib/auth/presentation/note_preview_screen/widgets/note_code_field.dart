import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/app/theme/gpt_markdown_theme_data.dart';

final class NoteCodeField extends StatefulWidget {
  final String name;
  final String codes;

  const NoteCodeField({super.key, required this.name, required this.codes});

  @override
  State<NoteCodeField> createState() => _NoteCodeFieldState();
}

final class _NoteCodeFieldState extends State<NoteCodeField> {
  static const Duration _copyFeedbackDuration = Duration(seconds: 2);
  static const textStyle = TextStyle(
    fontFamily: 'JetBrainsMono',
    package: 'gpt_markdown',
  );

  bool _copied = false;
  @override
  Widget build(BuildContext context) {
    final mdTheme = Theme.of(context).extension<AppGptMarkdownTheme>()!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: mdTheme.codeBlocBackground,
              borderRadius: BorderRadius.circular(Sizes.radiusSmall),
            ),
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(
                  top: Sizes.indent,
                  left: Sizes.indent2x,
                  bottom: Sizes.indent,
                ),
                child: Text(
                  widget.codes.trim(),
                  style: textStyle.copyWith(color: mdTheme.codeBlocColor),
                ),
              ),
            ),
          ),
        ),
        CupertinoButton(
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.indent2x,
            vertical: Sizes.indent,
          ),
          onPressed: _onCopy,
          child: Icon(_copied ? Icons.done : Icons.copy, size: Sizes.iconSmall),
        ),
      ],
    );
  }

  Future<void> _onCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.codes)).then((value) {
      if (mounted) {
        setState(() => _copied = true);
      }
    });
    await Future.delayed(_copyFeedbackDuration);
    if (mounted) {
      setState(() => _copied = false);
    }
  }
}

final class ShortNoteCodeField extends StatefulWidget {
  final String codes;

  const ShortNoteCodeField({super.key, required this.codes});

  @override
  State<ShortNoteCodeField> createState() => _ShortNoteCodeFieldState();
}

final class _ShortNoteCodeFieldState extends State<ShortNoteCodeField> {
  static const Duration _copyFeedbackDuration = Duration(seconds: 2);
  static const textStyle = TextStyle(
    fontFamily: 'JetBrainsMono',
    package: 'gpt_markdown',
    fontSize: 14.0,
  );

  bool _copied = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mdTheme = theme.extension<AppGptMarkdownTheme>()!;
    return CupertinoButton(
      minimumSize: .zero,
      padding: EdgeInsets.zero,
      onPressed: _onCopy,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: mdTheme.codeBlocBackground,
          borderRadius: BorderRadius.circular(Sizes.radiusSmall),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.indent),
          child: Stack(
            children: [
              Visibility.maintain(
                visible: !_copied,
                child: Text(
                  widget.codes.trim(),
                  style: textStyle.copyWith(color: mdTheme.codeBlocColor),
                ),
              ),
              Positioned.fill(
                child: Visibility.maintain(
                  visible: _copied,
                  child: Center(
                    child: Text(
                      context.l10n.commonCopied,
                      style: textStyle.copyWith(color: mdTheme.codeBlocColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.codes)).then((value) {
      if (mounted) {
        setState(() => _copied = true);
      }
    });
    await Future.delayed(_copyFeedbackDuration);
    if (mounted) {
      setState(() => _copied = false);
    }
  }
}
