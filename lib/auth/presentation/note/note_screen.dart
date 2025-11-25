import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/note/bloc/note_screen_state.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';

import 'bloc/note_screen_bloc.dart';
import 'bloc/note_screen_event.dart';

final class NoteScreen extends StatelessWidget with DialogHelper {
  final PathParams? pathParams;
  const NoteScreen({
    super.key,
    this.pathParams,
  });

  void _listener(BuildContext context, NoteScreenState state) {
    switch (state) {
      case CommonState():
      case InitiaslLoadingState():
        break;
      case ErrorState():
        showError(context, error: state.e);
        break;
      case DidSaveState():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => NoteScreenBloc(pathParams: pathParams),
      child: BlocConsumer<NoteScreenBloc, NoteScreenState>(
        listener: _listener,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: AppBar(
              actions: const [
                // _EditButton(),
                // SizedBox(width: Sizes.indent2x),
                _SaveButton(),
                SizedBox(width: Sizes.indent2x),
              ],
            ),
            body: SafeArea(
              child: _Form(
                initialText: state.data.text,
              ),
            ),
          );
        },
      ),
    );
  }
}

final class _Form extends StatefulWidget {
  final String initialText;
  const _Form({required this.initialText});

  @override
  State<_Form> createState() => _FormState();
}

final class _FormState extends State<_Form> {
  late final _controller = TextEditingController(text: widget.initialText);
  late final _focusNode = FocusNode();
  bool hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChangeText);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NoteScreenBloc, NoteScreenState>(
      listenWhen: (a, b) =>
          a.data.text != b.data.text || a.data.editMode != b.data.editMode,
      buildWhen: (a, b) =>
          a is InitiaslLoadingState != b is InitiaslLoadingState ||
          a.data.editMode != b.data.editMode,
      listener: (context, state) {
        if (state is CommonState) {
          _controller.text = state.data.text;
        }

        if (state.data.editMode != _focusNode.hasFocus) {
          if (state.data.editMode) {
            _focusNode.requestFocus();
          } else {
            _focusNode.unfocus();
          }
        }
      },
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state is InitiaslLoadingState
              ? const SizedBox()
              : state.data.editMode
                  ? TextFormField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.all(Sizes.indent2x),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      minLines: null,
                      expands: true,
                      onTapOutside: (event) {
                        FocusScope.of(context).unfocus();
                      },
                    )
                  : GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      child: Markdown(
                        data: _controller.text,
                        padding: const EdgeInsets.all(12.0),
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(fontSize: 16),
                          strong: const TextStyle(fontWeight: FontWeight.bold),
                          em: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
        );
      },
    );
  }

  void _onChangeText() {
    context.read<NoteScreenBloc>().add(
          NoteScreenEvent.didChangeText(_controller.text),
        );
  }
}

final class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteScreenBloc, NoteScreenState>(
      buildWhen: (a, b) =>
          a.data.editMode != b.data.editMode ||
          a.data.isChanged != b.data.isChanged,
      builder: (context, state) {
        if (state.data.editMode) {
          return CupertinoButton(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            onPressed: () => _onSave(
              context,
              state.data.isChanged,
            ),
            child: Text(
              state.data.isChanged
                  ? context.l10n.commonButtonSave
                  : context.l10n.commonButtonDone,
            ),
          );
        } else {
          return CupertinoButton(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            onPressed: () {
              context.read<NoteScreenBloc>().add(
                    const NoteScreenEvent.changeEditMode(true),
                  );
            },
            child: Text(context.l10n.commonButtonEdit),
          );
        }
      },
    );
  }

  void _onSave(BuildContext context, bool isChanged) {
    FocusScope.of(context).unfocus();
    if (isChanged) {
      context.read<NoteScreenBloc>().add(const NoteScreenEvent.saveNote());
    } else {
      context.read<NoteScreenBloc>().add(
            const NoteScreenEvent.changeEditMode(false),
          );
    }
  }
}
