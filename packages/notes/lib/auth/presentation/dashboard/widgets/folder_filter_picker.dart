import 'package:common/app/theme/sizes.dart';
import 'package:common/l10n/localization.dart';
import 'package:common/presentation/buttons/prymary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/presentation/model/category_localization.dart';
import 'package:nostr_notes/common/presentation/layout/breakpoints.dart';
import 'package:nostr_notes/l10n/localization.dart';

/// Funnel button that opens the folder-filter picker. Filled with the
/// active-filter count badge once a filter is applied — see
/// FolderFilterChipsRow for the chip row shown alongside it.
final class FolderFilterButton extends StatelessWidget {
  static const _size = Sizes.indent4x;

  final int selectedCount;
  final VoidCallback onTap;

  const FolderFilterButton({
    super.key,
    required this.selectedCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = selectedCount > 0;

    return Tooltip(
      message: context.l10n.notesListFilterButtonTooltip,
      child: CupertinoButton(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Badge(
          isLabelVisible: isActive,
          label: Text('$selectedCount'),
          backgroundColor: theme.colorScheme.error,
          child: Container(
            width: _size,
            height: _size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(Sizes.radiusSmall),
            ),
            child: Icon(
              Icons.filter_alt_outlined,
              size: Sizes.iconMedium,
              color: isActive
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// One removable chip per active folder filter, shown between the toolbar
/// and the search field. Absent entirely while no filter is active — see
/// AllTabContent.showFolderFilterChips, which reserves the extra header
/// height only when this row is present.
final class FolderFilterChipsRow extends StatelessWidget {
  static const _chipHeight = 44.0;
  final Set<CategoryType> selected;
  final ValueChanged<CategoryType> onRemove;

  const FolderFilterChipsRow({
    super.key,
    required this.selected,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (selected.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: _chipHeight + Sizes.indent,
      child: Padding(
        padding: const EdgeInsets.only(
          left: Sizes.indent,
          right: Sizes.indent,
          bottom: Sizes.indent,
        ),
        child: ListView.builder(
          itemCount: selected.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final folder = selected.elementAt(index);
            return Padding(
              padding: EdgeInsets.only(
                right: index == selected.length - 1 ? 0.0 : Sizes.indent,
              ),
              child: Chip(
                avatar: Text(folder.symbol),
                label: Text(folder.getLocalizedName(context)),
                onDeleted: () => onRemove(folder),
              ),
            );
          },

        ),
      ),
    );
  }
}

mixin FolderFilterPickerHelper {
  void showFolderFilterPicker(
    BuildContext context, {
    required Map<CategoryType, int> folderCounts,
    required Set<CategoryType> selected,
    required ValueChanged<Set<CategoryType>> onApply,
  }) {
    final breakpoint = Breakpoint.activeBreakpointOf(context);
    if (breakpoint.isSmall) {
      _showBottomSheet(
        context,
        folderCounts: folderCounts,
        selected: selected,
        onApply: onApply,
      );
    } else {
      _showDialog(
        context,
        folderCounts: folderCounts,
        selected: selected,
        onApply: onApply,
      );
    }
  }

  void _showBottomSheet(
    BuildContext context, {
    required Map<CategoryType, int> folderCounts,
    required Set<CategoryType> selected,
    required ValueChanged<Set<CategoryType>> onApply,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _FolderFilterPickerContent(
        folderCounts: folderCounts,
        selected: selected,
        onApply: onApply,
      ),
    );
  }

  void _showDialog(
    BuildContext context, {
    required Map<CategoryType, int> folderCounts,
    required Set<CategoryType> selected,
    required ValueChanged<Set<CategoryType>> onApply,
  }) {
    const maxWidth = 500.0;
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.all(Sizes.indent2x),
          child: _FolderFilterPickerContent(
            folderCounts: folderCounts,
            selected: selected,
            onApply: onApply,
          ),
        ),
      ),
    );
  }
}

final class _FolderFilterPickerVM {
  final Map<CategoryType, int> folderCounts;
  late final ValueNotifier<Set<CategoryType>> selected;

  _FolderFilterPickerVM({
    required this.folderCounts,
    required Set<CategoryType> initialSelected,
  }) {
    selected = ValueNotifier<Set<CategoryType>>(initialSelected);
  }

  void dispose() {
    selected.dispose();
  }

  void setSelection(CategoryType type, bool? isSelected) {
    if (isSelected == true) {
      selected.value = Set.from(selected.value)..add(type);
    } else {
      selected.value = Set.from(selected.value)..remove(type);
    }
  }
}

final class _FolderFilterPickerContent extends StatefulWidget {
  final Map<CategoryType, int> folderCounts;
  final Set<CategoryType> selected;
  final ValueChanged<Set<CategoryType>> onApply;

  const _FolderFilterPickerContent({
    required this.folderCounts,
    required this.selected,
    required this.onApply,
  });

  @override
  State<_FolderFilterPickerContent> createState() =>
      _FolderFilterPickerContentState();
}

final class _FolderFilterPickerContentState
    extends State<_FolderFilterPickerContent> {
  late final _vm = _FolderFilterPickerVM(
    folderCounts: widget.folderCounts,
    initialSelected: widget.selected,
  );

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final folders = CategoryType.valuesList
        .where((type) => (widget.folderCounts[type] ?? 0) > 0)
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: Sizes.indent2x,
            right: Sizes.indent2x,
            top: Sizes.halfIndent,
            bottom: Sizes.indent2x,
          ),
          child: Text(
            context.l10n.notesListFilterSheetTitle,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const Divider(height: Sizes.thickness),
        if (folders.isEmpty)
          Padding(
            padding: const EdgeInsets.all(Sizes.indent2x),
            child: Text(
              context.l10n.notesFoldersEmptyStatePlaceholder,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: folders.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final type = folders[index];
              final count = widget.folderCounts[type] ?? 0;
              return ValueListenableBuilder(
                valueListenable: _vm.selected,
                builder: (context, selected, child) {
                  final isSelected = selected.contains(type);
                  return CheckboxListTile.adaptive(
                    value: isSelected,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: theme.colorScheme.primary,
                    horizontalTitleGap: 0.0,
                    title: Row(
                      spacing: Sizes.indent,
                      children: [
                        Text(
                          type.symbol,
                          style: const TextStyle(fontSize: Sizes.iconMedium),
                        ),
                        Expanded(child: Text(type.getLocalizedName(context))),
                        Text(
                          '$count',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    onChanged: (isSelected) =>
                        _vm.setSelection(type, isSelected),
                  );
                },
              );
            },
          ),
        const Divider(height: Sizes.thickness),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: Sizes.indent2x,
              right: Sizes.indent2x,
              top: Sizes.indent2x,
            ),
            child: Center(
              child: PrymaryButton(
                title: context.commonL10n.commonButtonDone,
                onTap: () {
                  Navigator.of(context).maybePop();
                  widget.onApply(_vm.selected.value);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
