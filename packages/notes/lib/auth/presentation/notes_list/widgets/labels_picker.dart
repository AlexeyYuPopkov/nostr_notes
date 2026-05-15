import 'package:collection/collection.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/l10n/localization.dart';
import 'package:common/presentation/buttons/prymary_button.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/presentation/model/category_localization.dart';
import 'package:nostr_notes/common/presentation/layout/breakpoints.dart';
import 'package:nostr_notes/l10n/localization.dart';

mixin LabelsPickerHelper {
  void showLabelsPicker(
    BuildContext context, {
    required Note note,
    required ValueChanged<List<CategoryType>> onApply,
  }) {
    final breakpoint = Breakpoint.activeBreakpointOf(context);
    if (breakpoint.isSmall) {
      _showLabelsBottomSheet(context, note: note, onApply: onApply);
    } else {
      _showLabelsDialog(context, note: note, onApply: onApply);
    }
  }

  void _showLabelsBottomSheet(
    BuildContext context, {
    required Note note,
    required ValueChanged<List<CategoryType>> onApply,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _LabelsPickerContent(note: note, onApply: onApply),
    );
  }

  void _showLabelsDialog(
    BuildContext context, {
    required Note note,
    required ValueChanged<List<CategoryType>> onApply,
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
          child: _LabelsPickerContent(
            note: note,
            onApply: (labels) {
              Navigator.of(dialogContext).pop();
              onApply(labels);
            },
          ),
        ),
      ),
    );
  }
}

final class _LabelsPickerVM {
  final Note note;
  late final Set<CategoryType> _initialSelected;
  late final ValueNotifier<Set<CategoryType>> selected;

  _LabelsPickerVM({required this.note}) {
    final initialSelected = note.labels
        .whereType<Label>()
        .map((l) => l.type)
        .where((t) => t != CategoryType.other)
        .toSet();
    selected = ValueNotifier<Set<CategoryType>>(initialSelected);
    _initialSelected = initialSelected;
  }

  void dispose() {
    selected.dispose();
  }

  bool get canUpdate =>
      SetEquality().equals(selected.value, _initialSelected) == false;

  void setSelection(CategoryType type, bool? isSelected) {
    if (isSelected == true) {
      selected.value = Set.from(selected.value)..add(type);
    } else {
      selected.value = Set.from(selected.value)..remove(type);
    }
  }
}

final class _LabelsPickerContent extends StatefulWidget {
  final Note note;
  final void Function(List<CategoryType> labels) onApply;

  const _LabelsPickerContent({required this.note, required this.onApply});

  @override
  State<_LabelsPickerContent> createState() => _LabelsPickerContentState();
}

final class _LabelsPickerContentState extends State<_LabelsPickerContent> {
  late final _LabelsPickerVM _vm = _LabelsPickerVM(note: widget.note);

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = CategoryType.valuesList.toList();

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
            context.l10n.notesListAssignFolder,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const Divider(height: Sizes.thickness),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final type = categories[index];
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
                      Text(type.getLocalizedName(context)),
                    ],
                  ),
                  onChanged: (isSelected) => _vm.setSelection(type, isSelected),
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
            child: ValueListenableBuilder(
              valueListenable: _vm.selected,
              builder: (context, selected, child) {
                return Center(
                  child: PrymaryButton(
                    title: context.commonL10n.commonButtonDone,
                    onTap: _vm.canUpdate
                        ? () {
                            widget.onApply(selected.toList());
                          }
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
