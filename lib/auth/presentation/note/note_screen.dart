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
    return GestureDetector(
      onLongPress: () {
        setState(() {
          hasFocus = !hasFocus;
        });
      },
      child: BlocConsumer<NoteScreenBloc, NoteScreenState>(
        listenWhen: (a, b) => a.data.text != b.data.text,
        buildWhen: (a, b) =>
            a is InitiaslLoadingState != b is InitiaslLoadingState,
        listener: (context, state) {
          if (state is CommonState) {
            _controller.text = state.data.text;
          }
        },
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: state is InitiaslLoadingState
                ? const SizedBox()
                : hasFocus
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
          );
        },
      ),
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
    FocusScope.of(context).unfocus();
    context.read<NoteScreenBloc>().add(const NoteScreenEvent.saveNote());
  }
}

// final class _Shimmers extends StatelessWidget {
//   const _Shimmers();

//   @override
//   Widget build(BuildContext context) {
//     const text = '''
// Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
// tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
// quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
// Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
// Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
// ''';
//     return const Padding(
//       padding: EdgeInsets.symmetric(horizontal: Sizes.indent2x),
//       child: CommonShimmer(
//         child: Markdown(
//           data: text,
//         ),
//       ),
//     );
//   }
// }
