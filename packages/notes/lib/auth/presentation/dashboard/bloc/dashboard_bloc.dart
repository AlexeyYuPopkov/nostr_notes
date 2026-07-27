import 'package:di_storage/di_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/repo/notes_list_tab_repo.dart';

import 'package:nostr_notes/auth/presentation/dashboard/notes_list_tab.dart';

import 'package:rxdart/rxdart.dart';

import 'dashboard_data.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

final class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  static const debounceGuard = Duration(milliseconds: 200);
  DiStorage get _di => DiStorage.shared;



  DashboardData get data => state.data;
  late final NotesListTabRepo _tabRepo = _di.resolve();

  DashboardBloc()
    : super(DashboardState.common(data: DashboardData.initial())) {
    _setupHandlers();

    add(const DashboardEvent.initial());
  }

  @override
  Future<void> close() async {
    
    await super.close();
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
    on<SelectTabEvent>(
      _onSelectFolderEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceGuard).switchMap(mapper),
    );
  }

  void _onInitialEvent(InitialEvent event, Emitter<DashboardState> emit) async {
    try {
      final savedTabIndex = _tabRepo.getTabIndex();
      final savedTab =
          NotesListTab.tabs.elementAtOrNull(savedTabIndex) ??
          NotesListTab.tabs.first;

      emit(DashboardState.common(data: data.copyWith(tab: savedTab)));
    } catch (e) {
      emit(DashboardState.error(e: e, data: data));
    }
  }

  void _onSelectFolderEvent(
    SelectTabEvent event,
    Emitter<DashboardState> emit,
  ) {
    if (isClosed) {
      return;
    }

    _tabRepo.setTabIndex(event.tab.index);
    emit(DashboardState.common(data: data.copyWith(tab: event.tab)));

    // Leaving with an active search → reset it so returning to "All" starts
    // clean. Reuses the (restartable, async-safe) search handler to rebuild
    // sections from the full set.
    // if (data.searchString.trim().isNotEmpty) {
    //   add(const NotesListEvent.search(''));
    // }
  }
}
