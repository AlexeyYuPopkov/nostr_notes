import 'package:flutter/material.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class NotesSearchField extends StatefulWidget {
  final String initialQuery;
  final ValueChanged<String> onChanged;

  /// Placeholder text; defaults to the notes search hint when null.
  final String? hintText;

  const NotesSearchField({
    super.key,
    required this.initialQuery,
    required this.onChanged,
    this.hintText,
  });

  @override
  State<NotesSearchField> createState() => _NotesSearchFieldState();
}

final class _NotesSearchFieldState extends State<NotesSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialQuery,
  );

  late final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(BuildContext context, String value) {
    widget.onChanged(value);
    
    setState(() {}); // toggle the clear button
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textInputAction: TextInputAction.search,
      onChanged: (value) => _onChanged(context, value),
      onTapOutside: (event) => _focusNode.unfocus(),
      decoration: InputDecoration(
        isDense: true,
        hintText: widget.hintText ?? l10n.notesListSearchHint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _focusNode.unfocus();
                  _controller.clear();
                  _onChanged(context, '');
                },
              )
            : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
