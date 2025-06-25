import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      case LoadingState():
        break;
      case ErrorState():
        showError(context, error: state.e);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
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
              child: TextFormField(
                key: ValueKey(state.data.text),
                initialValue: state.data.text,
                onChanged: (str) => _onChangeText(context, str),
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
              ),
            ),
          );
        },
      ),
    );
  }

  void _onChangeText(BuildContext context, String text) {
    context.read<NoteScreenBloc>().add(NoteScreenEvent.didChangeText(text));
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
