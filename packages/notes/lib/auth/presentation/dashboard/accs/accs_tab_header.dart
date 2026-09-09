import 'package:common/app/theme/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/presentation/dashboard/accs/bloc/accs_bloc.dart';
import 'package:nostr_notes/auth/presentation/dashboard/accs/bloc/accs_event.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes_list_tab.dart';
import 'package:nostr_notes/auth/presentation/dashboard/widgets/notes_search_field.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class AccsTabHeader extends StatelessWidget {
  final HeaderParams params;
  const AccsTabHeader({super.key, required this.params});

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('search_accs'),
      padding: const EdgeInsets.only(
        left: Sizes.indent,
        right: Sizes.indent,
        bottom: Sizes.indent,
      ),
      child: NotesSearchField(
        initialQuery: params.searchQuery,
        hintText: context.l10n.accsSearchHint,
        onChanged: (value) =>
            context.read<AccsBloc>().add(AccsEvent.search(value)),
      ),
    );
  }
}
