import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/tools/section_scroll_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/presentation/model/category_localization.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes/bloc/notes_list_bloc.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class FolderBackButton extends StatelessWidget {
  final SectionScrollVm scrollVm;
  const FolderBackButton({super.key, required this.scrollVm});

  @override
  Widget build(BuildContext context) {
    final foldersVm = context.read<NotesListBloc>().foldersVm;
    return ListenableBuilder(
      key: const ValueKey('folders'),
      listenable: foldersVm,
      builder: (context, _) {
        final folder = foldersVm.folder;
        if (folder == null) return const SizedBox.shrink();
        return _FolderBackButton(
          folder: folder,
          onBack: () {
            scrollVm.clearSections();
            foldersVm.setFolder(null, context.l10n);
          },
        );
      },
    );
  }
}

final class _FolderBackButton extends StatelessWidget {
  final CategoryType folder;
  final VoidCallback onBack;
  const _FolderBackButton({required this.folder, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CupertinoButton(
      minimumSize: Size.zero,
      padding: const EdgeInsets.only(
        left: Sizes.indent,
        right: Sizes.indent,
        top: Sizes.indentVariant2x,
      ),
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
    );
  }
}
