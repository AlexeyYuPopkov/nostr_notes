
import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/tools/section_scroll_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes_list_tab.dart';
import '../widgets/folder_filter_picker.dart';
import 'notes_list_screen_toolbar.dart';

final class NoteListHeaderVm extends ChangeNotifier {
  /// Scroll chrome shared by every tab's [NestedScrollView] instance — each
  /// tab keeps its own `SectionScrollVm` (typed to that tab's section
  /// headers) but they all listen to this one controller.
  late final scrollController = ScrollController();

  /// 1.0 = header fully shown, 0.0 = fully hidden. Below one header-height
  /// of [scrollOffset], `_Header` tracks [scrollOffset] directly instead of
  /// reading this — this notifier only matters (and is only written to)
  /// once you've scrolled past that point, where it drives the same
  /// direction-based show/hide snap as before, just expressed as 1.0/0.0
  /// instead of a bool.
  late final headerVisibility = ValueNotifier<double>(1.0);

  /// Live scroll offset of whichever inner tab is currently scrolling, fed
  /// from `ScrollUpdateNotification.metrics.pixels` bubbled up through
  /// `NotificationListener` in `_DashboardState._onScrollNotification`.
  /// [scrollController] itself can't be used for this — it's the *outer*
  /// `NestedScrollView` position, which never moves since
  /// `headerSliverBuilder` is empty; all real scrolling happens on the
  /// inner tab scroll views.
  late final scrollOffset = ValueNotifier<double>(0.0);

  @override
  void dispose() {
    scrollController.dispose();
    headerVisibility.dispose();
    scrollOffset.dispose();
    super.dispose();
  }

  bool onScrollNotification(ScrollNotification notification) {
    // final dashboardBloc = context.read<DashboardBloc>();
    final metrics = notification.metrics;

    // if (metrics.pixels <= metrics.minScrollExtent) {
    //   scrollOffset.value = 0.0;
    //   headerVisibility.value = 1.0;
    //   return false;
    // }

    if (notification is ScrollUpdateNotification) {
      scrollOffset.value = metrics.pixels;
    }

    // if (metrics.pixels < NoteListHeader.approxHeaderHeight) {
    //   // Proportional zone: track every live update 1:1 — direction doesn't
    //   // matter here, only how far from the top we are. headerVisibility is
    //   // left untouched; _Header ignores it in this zone anyway.
    //   if (notification is ScrollUpdateNotification) {
    //     scrollOffset.value = metrics.pixels;
    //   }
    //   // return false;
    // }

    // scrollOffset.value = metrics.pixels;

    // Past one header-height: existing direction-based show/hide snap.
    if (notification is UserScrollNotification && !metrics.outOfRange) {
      switch (notification.direction) {
        case ScrollDirection.reverse:
          headerVisibility.value = 0.0;
        case ScrollDirection.forward:
          headerVisibility.value = 1.0;
        case ScrollDirection.idle:
          break;
      }
    }

    return false;
  }
}

final class NoteListHeader extends StatelessWidget {
  static const double _approxHeaderHeightFilters = 156.0;
  static const double _approxHeaderHeight = 56.0 + 48.0; // toolbar + tab bar

  final SectionScrollVm scrollVm;
  final NoteListHeaderVm _vm;
  final NotesListTab tab;
  final String searchString;
  final Set<CategoryType> filters;
  final ValueChanged<CategoryType> onRemoveFilter;

  const NoteListHeader({
    super.key,
    required this.scrollVm,
    required NoteListHeaderVm vm,
    required this.searchString,
    required this.tab,
    required this.filters,
    required this.onRemoveFilter,
  }) : _vm = vm;

  double get approxHeaderHeight {
    if (tab is NotesNotesTab) {
      return filters.isNotEmpty
          ? _approxHeaderHeightFilters
          : _approxHeaderHeight;
    }
    return _approxHeaderHeight;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: approxHeaderHeight,
      child: ListenableBuilder(
        listenable: Listenable.merge([_vm.scrollOffset, _vm.headerVisibility]),
        builder: (context, child) {
          final offset = _vm.scrollOffset.value;

          if (offset < approxHeaderHeight && _vm.headerVisibility.value < 1.0) {
            final ratio = (offset / approxHeaderHeight).clamp(0.0, 1.0);
            // log('ratio: ${ratio.toString()}', name: 'Header');
            // log(
            //   'headerVisibility: ${_vm.headerVisibility.value.toString()}',
            //   name: 'Header',
            // );
            return FractionalTranslation(
              translation: Offset(0.0, -ratio),
              child: child,
            );
          }

          // log(
          //   'headerVisibility: ${_vm.headerVisibility.value.toString()}',
          //   name: 'Header',
          // );

          return AnimatedSlide(
            duration: const Duration(milliseconds: 200),
            offset: _vm.headerVisibility.value >= 0.5
                ? Offset.zero
                : const Offset(0.0, -1.0),
            curve: Curves.easeInOut,
            child: child,
          );
        },
        child: ColoredBox(
          color: theme.scaffoldBackgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: Sizes.indent),
                  child: NotesListScreenToolbar(),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (tab is NotesNotesTab)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FolderFilterChipsRow(
                        selected: filters,
                        onRemove: onRemoveFilter,
                      ),
                    ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: tab.buildHeader(
                      context,
                      params: HeaderParams(
                        searchQuery: searchString,
                        scrollSectionsVm: scrollVm,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
