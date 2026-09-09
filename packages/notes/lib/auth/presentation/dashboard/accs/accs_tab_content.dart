import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/tools/list_item_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/presentation/dashboard/accs/bloc/accs_bloc.dart';
import 'package:nostr_notes/auth/presentation/dashboard/accs/bloc/accs_data.dart';
import 'package:nostr_notes/auth/presentation/dashboard/accs/bloc/accs_event.dart';
import 'package:nostr_notes/auth/presentation/dashboard/accs/bloc/accs_state.dart';
import 'package:nostr_notes/services/ads/ad_banner.dart';
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

        if (data.visibleItems.isEmpty) {
          return _AccsEmpty(isSearching: data.isSearching);
        }

        final rows = data.displayItems;
        final positions = _cardPositions(rows);

        return RefreshIndicator.adaptive(
          displacement: kNotesListHeaderWithSearch,
          onRefresh: () => _onRefresh(context),
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: SizedBox(height: kNotesListHeaderWithSearch),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: rows.length + 1,
                  (context, index) {
                    if (index == 0) {
                      return NotesListSectionHeader(
                        title: context.l10n.accsSectionAll,
                        isFirst: true,
                      );
                    }
                    final rowIndex = index - 1;
                    return switch (rows[rowIndex]) {
                      AccsDataLoginItem(:final item) => AccountListCard(
                        item: item,
                        position: positions[rowIndex]!,
                        onTap: onDetails,
                        onDelete: (item) => context.read<AccsBloc>().add(
                          AccsEvent.deleteItem(item),
                        ),
                      ),
                      AccsDataAdBanner() => const _AccsAdSlot(),
                    };
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: Sizes.indent4x + MediaQuery.paddingOf(context).bottom,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onRefresh(BuildContext context) {
    context.read<AccsBloc>().add(const AccsEvent.sync());
    return Future.delayed(Durations.extralong1);
  }

  /// Rounded corners and separators group adjacent cards into one block, so
  /// a position has to be read within its own run rather than the whole
  /// list: the banner splits the run, and the card above it has to render as
  /// the last of its group instead of a middle one. Null where a row is the
  /// banner itself.
  static List<ListItemPosition?> _cardPositions(List<AccsDataItem> rows) {
    final positions = List<ListItemPosition?>.filled(rows.length, null);
    var runStart = 0;

    void closeRun(int end) {
      final length = end - runStart;
      for (var i = 0; i < length; i++) {
        positions[runStart + i] = ListItemPosition.fromIndex(i, length: length);
      }
    }

    for (var i = 0; i < rows.length; i++) {
      if (rows[i] is AccsDataLoginItem) continue;
      closeRun(i);
      runStart = i + 1;
    }
    closeRun(rows.length);

    return positions;
  }
}

/// Keeps the banner visually apart from the credential cards it sits
/// between: an ad that reads as another account row would invite taps meant
/// for the list.
final class _AccsAdSlot extends StatelessWidget {
  const _AccsAdSlot();

  @override
  Widget build(BuildContext context) {
    if (!AdBanner.isSupported) return const SizedBox.shrink();

    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Sizes.indent,
        vertical: Sizes.indent2x,
      ),
      child: Center(child: AdBanner()),
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
