import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes/bloc/notes_list_bloc.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes/bloc/notes_list_event.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes/bloc/notes_list_state.dart';
import 'package:nostr_notes/auth/presentation/dashboard/widgets/folder_filter_picker.dart';

final class NotesFolderFilterButton extends StatelessWidget
    with FolderFilterPickerHelper {
  const NotesFolderFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<NotesListBloc, NotesListState, Set<CategoryType>>(
      selector: (state) => state.data.folderFilter,
      builder: (context, folderFilter) {
        return FolderFilterButton(
          selectedCount: folderFilter.length,
          onTap: () => _onFilterTap(context, selected: folderFilter),
        );
      },
    );
  }

  void _onFilterTap(
    BuildContext context, {
    required Set<CategoryType> selected,
  }) {
    final bloc = context.read<NotesListBloc>();
    showFolderFilterPicker(
      context,
      folderCounts: bloc.folderCounts,
      selected: selected,
      onApply: (folders) => bloc.add(NotesListEvent.setFolderFilter(folders)),
    );
  }
}
