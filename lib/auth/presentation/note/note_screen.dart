import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/note/bloc/note_screen_state.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';
// import 'package:notus_format/convert.dart';
// import 'package:zefyrka/zefyrka.dart';

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
      case LoadingState():
        break;
      case ErrorState():
        showError(context, error: state.e);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NoteScreenBloc(pathParams: pathParams),
      child: BlocConsumer<NoteScreenBloc, NoteScreenState>(
        listener: _listener,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              actions: const [
                _SaveButton(),
                SizedBox(width: Sizes.indent2x),
              ],
            ),
            body: SafeArea(
              child: _Form(
                // key: ValueKey(state.data.text),
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
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && hasFocus) {
        setState(() {
          hasFocus = false;
        });
      }
      // else if (_focusNode.hasFocus && !hasFocus) {
      //   setState(() {
      //     hasFocus = false;
      //   });
      // }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NoteScreenBloc, NoteScreenState>(
      listenWhen: (a, b) => a.data.text != b.data.text,
      listener: (context, state) {
        if (_controller.text != state.data.text) {
          _controller.text = state.data.text;
        }
      },
      child: GestureDetector(
          onLongPress: () {
            setState(() {
              hasFocus = !hasFocus;
            });
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: hasFocus
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
                : Markdown(
                    data: _controller.text,
                    padding: const EdgeInsets.all(12.0),
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(fontSize: 16),
                      strong: const TextStyle(fontWeight: FontWeight.bold),
                      em: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
          )),
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
    return BlocSelector<NoteScreenBloc, NoteScreenState, bool>(
      selector: (state) {
        return state.data.isChanged;
      },
      builder: (context, isEnabled) {
        return CupertinoButton(
          minSize: Sizes.zero,
          padding: EdgeInsets.zero,
          onPressed: isEnabled ? () => _onSave(context) : null,
          child: Text(context.l10n.commonButtonSave),
        );
      },
    );
  }

  void _onSave(BuildContext context) {
    context.read<NoteScreenBloc>().add(const NoteScreenEvent.saveNote());
  }
}
