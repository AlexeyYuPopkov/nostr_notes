import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/tools/section_scroll_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/presentation/model/category_localization.dart';
import 'package:nostr_notes/auth/presentation/notes_list/tabs/all_tab_content.dart';
import 'package:nostr_notes/auth/presentation/notes_list/widgets/labels_picker.dart';
import 'package:nostr_notes/auth/presentation/widgets/new_note_prompt_placeholder.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';
import 'package:nostr_notes/l10n/app_localizations.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class FoldersTabContentVM extends ChangeNotifier {
  Map<CategoryType, List<Note>> _folders;
  CategoryType? _folder;
  List<NotesListSection> _sections;

  FoldersTabContentVM._({
    required List<NotesListSection> sections,
    required Map<CategoryType, List<Note>> folders,
    required CategoryType? folder,
  }) : _sections = sections,
       _folders = folders;

  factory FoldersTabContentVM.fromNotes(
    List<Note> notes,
    CategoryType? folder,
    AppLocalizations l10n,
  ) {
    final folders = createFolders(notes);
    return FoldersTabContentVM._(
      sections: createSections(notes, folder, l10n),
      folders: folders,
      folder: folder,
    );
  }

  int getCount({required CategoryType folder}) => _folders[folder]?.length ?? 0;
  List<CategoryType> getFolders() => _folders.keys.toList();
  CategoryType? get folder => _folder;

  void setNotes(List<Note> notes, AppLocalizations l10n) {
    _folders = createFolders(notes);
    _sections = createSections(notes, _folder, l10n);
    notifyListeners();
  }

  void setFolder(CategoryType? folder, AppLocalizations l10n) {
    _folder = folder;
    if (folder == null) {
      _sections = [];
    } else {
      _sections = createSections(_folders[folder] ?? [], folder, l10n);
    }

    notifyListeners();
  }

  static List<NotesListSection> createSections(
    List<Note> notes,
    CategoryType? folder,
    AppLocalizations l10n,
  ) {
    if (folder == null) {
      return [];
    }
    final filtered = filterNotes(notes, folder);

    final sections = NotesListSection.groupNotesByDate(
      notes: filtered,
      l10n: l10n,
    );

    return sections;
  }

  static List<Note> filterNotes(List<Note> notes, CategoryType folder) {
    return notes
        .where((e) => e.labels.whereType<Label>().any((e) => e.type == folder))
        .toList();
  }

  static Map<CategoryType, List<Note>> createFolders(List<Note> notes) {
    final folders = <CategoryType, List<Note>>{};
    for (final note in notes) {
      final labels = note.labels.whereType<Label>();
      for (final label in labels) {
        final type = label.type;
        folders[type] = [...?folders[type], note];
      }
    }

    return folders;
  }
}

final class FoldersTabContent extends StatelessWidget {
  final FoldersTabContentVM vm;
  final String? selectedNoteDTag;
  final bool isLoading;
  final ValueChanged<Note> onTap;
  final SectionScrollVm _scrollSectionsVm;

  const FoldersTabContent({
    super.key,
    required this.vm,
    required this.selectedNoteDTag,
    required this.isLoading,
    required this.onTap,
    required SectionScrollVm scrollSectionsVm,
  }) : _scrollSectionsVm = scrollSectionsVm;

  void _openFolder(BuildContext context, CategoryType folder) {
    vm.setFolder(folder, context.l10n);
  }

  void _closeFolder(BuildContext context) {
    vm.setFolder(null, context.l10n);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final folder = vm._folder;
        return AnimatedSwitcher(
          duration: AppDurations.medium,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final isDetail = child.key == const ValueKey('detail');
            final begin = isDetail
                ? const Offset(1.0, 0.0)
                : const Offset(-1.0, 0.0);
            final slide = Tween<Offset>(
              begin: begin,
              end: Offset.zero,
            ).animate(animation);
            return SlideTransition(position: slide, child: child);
          },
          child: folder != null
              ? KeyedSubtree(
                  key: const ValueKey('detail'),
                  child: _FolderDetail(
                    folder: folder,
                    selectedNoteDTag: selectedNoteDTag,
                    isLoading: isLoading,
                    sections: vm._sections,
                    onTap: onTap,
                    onBack: () => _closeFolder(context),
                    scrollSectionsVm: _scrollSectionsVm,
                  ),
                )
              : KeyedSubtree(
                  key: const ValueKey('list'),
                  child: _FolderGrid(
                    vm: vm,
                    onTap: (labelType) => _openFolder(context, labelType),
                  ),
                ),
        );
      },
    );
  }
}

final class _FolderGrid extends StatelessWidget {
  final FoldersTabContentVM _vm;
  final ValueChanged<CategoryType> onTap;

  const _FolderGrid({required FoldersTabContentVM vm, required this.onTap})
    : _vm = vm;

  @override
  @override
  Widget build(BuildContext context) {
    final folders = _vm.getFolders();
    if (folders.isEmpty) {
      return Center(
        child: NewNotePromptPlaceholder(
          text: context.l10n.notesFoldersEmptyStatePlaceholder,
        ),
      );
    }

    final mediaPadding = MediaQuery.paddingOf(context);

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        Sizes.indent2x,
        Sizes.indent2x,
        Sizes.indent2x,
        Sizes.indent2x + mediaPadding.bottom,
      ),
      itemCount: folders.length,
      separatorBuilder: (_, __) => const SizedBox(height: Sizes.indent),
      itemBuilder: (context, index) {
        final folder = folders[index];
        final count = _vm.getCount(folder: folder);
        return _FolderCard(folder: folder, count: count, onTap: onTap);
      },
    );
  }
}

final class _FolderCard extends StatelessWidget {
  final CategoryType folder;
  final int count;
  final ValueChanged<CategoryType> onTap;

  const _FolderCard({
    required this.folder,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final symbol = Label.categorySymbols[folder.name] ?? Label.other;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => onTap(folder),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0.5,
        margin: EdgeInsets.zero,
        shadowColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.indentVariant,
            vertical: Sizes.indentVariant,
          ),
          child: Row(
            children: [
              const SizedBox(width: Sizes.indent),
              Text(
                symbol,
                style: const TextStyle(fontSize: TextSizes.headline),
              ),
              const SizedBox(width: Sizes.indent2x),
              Expanded(
                child: Text(
                  folder.getLocalizedName(context),
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$count',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: Sizes.halfIndent),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _FolderDetail extends StatelessWidget with LabelsPickerHelper {
  final CategoryType folder;
  final String? selectedNoteDTag;
  final bool isLoading;
  final List<NotesListSection> sections;
  final ValueChanged<Note> onTap;
  final VoidCallback onBack;
  final SectionScrollVm _scrollSectionsVm;

  const _FolderDetail({
    required this.folder,
    required this.selectedNoteDTag,
    required this.isLoading,
    required this.sections,
    required this.onTap,
    required this.onBack,
    required SectionScrollVm scrollSectionsVm,
  }) : _scrollSectionsVm = scrollSectionsVm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        CupertinoButton(
          padding: EdgeInsets.symmetric(horizontal: Sizes.indent2x),
          onPressed: onBack,
          child: Row(
            children: [
              Icon(
                Icons.arrow_back_ios,
                size: Sizes.iconSmall,
                color: theme.colorScheme.onSurface,
              ),
              Text(
                folder.getLocalizedName(context),
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        Expanded(
          child: AllTabContent(
            selectedNoteDTag: selectedNoteDTag,
            isLoading: isLoading,
            sections: sections,
            onTap: onTap,
            scrollSectionsVm: _scrollSectionsVm,
          ),
        ),
      ],
    );
  }
}
