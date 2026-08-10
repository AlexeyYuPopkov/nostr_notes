import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/tools/list_item_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/presentation/dashboard/accs/bloc/accs_bloc.dart';
import 'package:nostr_notes/auth/presentation/dashboard/accs/bloc/accs_event.dart';
import 'package:nostr_notes/auth/presentation/dashboard/accs/bloc/accs_state.dart';
import 'package:nostr_notes/auth/presentation/dashboard/accs/widgets/account_list_card.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes_list_tab.dart';
import 'package:nostr_notes/auth/presentation/dashboard/widgets/notes_list_section_header.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class AccsTabContent extends StatelessWidget {
  final ValueChanged<LoginItem>? onDetails;
  const AccsTabContent({super.key, required this.onDetails});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccsBloc, AccsState>(
      builder: (context, state) {
        if (state is LoadingState) {
          return const _AccsShimmerList();
        }

        final data = state.data;
        final items = data.visibleItems;

        if (items.isEmpty) {
          return _AccsEmpty(isSearching: data.isSearching);
        }

        final itemsLength = items.length;

        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(height: kNotesListHeaderWithSearch),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: itemsLength + 1,
                (context, index) {
                  if (index == 0) {
                    return NotesListSectionHeader(
                      title: context.l10n.accsSectionAll,
                      isFirst: true,
                    );
                  }
                  final itemIndex = index - 1;
                  return AccountListCard(
                    item: items[itemIndex],
                    position: ListItemPosition.fromIndex(
                      itemIndex,
                      length: itemsLength,
                    ),
                    onTap: onDetails,
                    onDelete: (item) =>
                        context.read<AccsBloc>().add(AccsEvent.deleteItem(item)),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: Sizes.indent4x + MediaQuery.paddingOf(context).bottom,
              ),
            ),
          ],
        );
      },
    );
  }
}

final class _AccsEmpty extends StatelessWidget {
  final bool isSearching;
  const _AccsEmpty({required this.isSearching});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(
        top: kNotesListHeaderWithSearch,
        left: Sizes.indent4x,
        right: Sizes.indent4x,
      ),
      child: Center(
        child: Text(
          isSearching ? l10n.notesListSearchNothingFound : l10n.accsEmptyTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

final class _AccsShimmerList extends StatelessWidget {
  static const _placeholdersCount = 8;
  const _AccsShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: kNotesListHeaderWithSearch),
      itemCount: _placeholdersCount,
      itemBuilder: (context, index) => _AccsCardShimmer(
        position: ListItemPosition.fromIndex(index, length: _placeholdersCount),
      ),
    );
  }
}

final class _AccsCardShimmer extends StatelessWidget {
  final ListItemPosition position;
  const _AccsCardShimmer({required this.position});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Sizes.indent),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: position.getRadius(),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Sizes.indent2x,
          vertical: Sizes.indentVariant2x,
        ),
        child: Row(
          children: [
            _ShimmerBox(width: 40, height: 40, radius: Sizes.radiusSmall),
            SizedBox(width: Sizes.indent2x),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: 120, height: 16),
                  SizedBox(height: Sizes.halfIndent),
                  _ShimmerBox(width: 180, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = Sizes.radiusSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

abstract interface class AccsTabCoordinator {
  const AccsTabCoordinator();

  void onTapLoginItem(BuildContext context, LoginItem item);
}
