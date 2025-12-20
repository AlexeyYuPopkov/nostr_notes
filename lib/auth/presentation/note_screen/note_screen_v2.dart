import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/note_screen/bloc/note_bloc.dart';
import 'package:nostr_notes/auth/presentation/note_screen/bloc/note_bloc_event.dart';
import 'package:nostr_notes/auth/presentation/note_screen/bloc/note_bloc_state.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';

final class NoteScreenV2 extends StatelessWidget with DialogHelper {
  final PathParams? pathParams;
  final config = _Config();

  NoteScreenV2({super.key, this.pathParams});

  void _listener(BuildContext context, NoteBlocState state) {
    switch (state) {
      case CommonState():
        break;
      case LoadingState():
        break;
      case ErrorState():
        showError(context, error: state.e);
        break;
      case DidSaveState():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved successfully')));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => NoteBloc(pathParams: pathParams),
      child: BlocConsumer<NoteBloc, NoteBlocState>(
        listener: _listener,
        builder: (context, state) {
          final controller = context.read<NoteBloc>().controller;
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
              child: Padding(
                padding: const EdgeInsets.all(Sizes.indent),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: QuillSimpleToolbar(
                            controller: controller,
                            config: config.config,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 44.0),
                    Expanded(
                      child: QuillEditor.basic(
                        controller: controller,
                        // focusNode: _focusNode,
                        scrollController: ScrollController(),
                        // scrollable: true,
                        // padding: EdgeInsets.zero,
                        // autoFocus: false,
                        // readOnly: false,
                        // placeholder: 'Напишите сообщение...',
                        // expands: false,
                        // customStyles: DefaultStyles(
                        //   paragraph: DefaultTextBlockStyle(
                        //     TextStyle(fontSize: 16, color: Colors.black87),
                        //     VerticalSpacing(4, 4),
                        //     VerticalSpacing(0, 0),
                        //     null,
                        //   ),
                        // ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

final class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<NoteBloc, NoteBlocState, bool>(
      selector: (state) => state.data.hasChanges,
      builder: (context, hasChanges) {
        return CupertinoButton(
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          onPressed: hasChanges ? () => _onSave(context) : null,
          child: Text(
            context.l10n.commonButtonSave,
            // state.data.isChanged
            //     ? context.l10n.commonButtonSave
            //     : context.l10n.commonButtonDone,
          ),
        );
      },
    );
  }

  void _onSave(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<NoteBloc>().add(const NoteBlocEvent.save());
  }
}

final class _Config {
  _Config();

  QuillSimpleToolbarConfig get config => const QuillSimpleToolbarConfig(
    toolbarIconAlignment: WrapAlignment.start,
    toolbarIconCrossAlignment: WrapCrossAlignment.start,
    multiRowsDisplay: false,
    showDividers: false,
    showFontFamily: false,
    showFontSize: true,
    showBoldButton: true,
    showItalicButton: false,
    showSmallButton: false,
    showUnderLineButton: false,
    showLineHeightButton: false,
    showStrikeThrough: false,
    showInlineCode: false,
    showColorButton: false,
    showBackgroundColorButton: false,
    showClearFormat: true,
    showAlignmentButtons: false,
    showLeftAlignment: false,
    showCenterAlignment: false,
    showRightAlignment: false,
    showJustifyAlignment: false,
    showHeaderStyle: false,
    showListNumbers: true,
    showListBullets: false,
    showListCheck: false,
    showCodeBlock: true,
    showQuote: false,
    showIndent: false,
    showLink: false,
    showUndo: true,
    showRedo: true,
    showDirection: false,
    showSearchButton: false,
    showSubscript: false,
    showSuperscript: false,
    //@experimental
    // showClipboardCut: true,
    //@experimental
    // showClipboardCopy: true,
    //@experimental
    // showClipboardPaste: true,
  );
}
