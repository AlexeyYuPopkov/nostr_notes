import 'dart:async';
import 'dart:developer';

import 'package:common/presentation/tools/section_scroll_vm.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/sync_login_items_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/watch_login_items_usecase.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';

import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_command.dart';
import '../../notes_list_tab.dart';
import 'accs_data.dart';
import 'accs_event.dart';
import 'accs_state.dart';

final class AccsBloc extends Bloc<AccsEvent, AccsState> {
  DiStorage get _di => DiStorage.shared;
  AccsData get data => state.data;

  late final WatchLoginItemsUsecase _watchLoginItems = _di.resolve();
  late final SyncLoginItemsUsecase _syncLoginItems = _di.resolve();

  final SectionScrollVm<NotesListHeader> sectionScrollVm;

  bool _isActive = false;

  StreamSubscription<List<LoginItem>>? _itemsSubscription;
  StreamSubscription<bool>? _dashboardTabSubscription;
  StreamSubscription<DashboardCommand>? _dashboardCommandSubscription;
  StreamSubscription<List<dynamic>>? _syncSubscription;

  AccsBloc({required DashboardBloc dashboardBloc})
    : sectionScrollVm = SectionScrollVm<NotesListHeader>(
        scrollController: dashboardBloc.scrollController,
      ),
      super(AccsState.loading(data: AccsData.initial())) {
    _setupHandlers();

    _isActive = dashboardBloc.state.data.tab is AccsTab;

    _dashboardTabSubscription = dashboardBloc.stream
        .map((state) => state.data.tab is AccsTab)
        .distinct()
        .listen((isActive) {
          _isActive = isActive;
          if (isActive) {
            add(const AccsEvent.sync());
          }
        });

    _dashboardCommandSubscription = dashboardBloc.commands.listen((_) {
      if (_isActive) {
        add(const AccsEvent.sync());
      }
    });

    add(const AccsEvent.initial());
  }

  @override
  Future<void> close() {
    _itemsSubscription?.cancel();
    _dashboardTabSubscription?.cancel();
    _dashboardCommandSubscription?.cancel();
    _syncSubscription?.cancel();
    sectionScrollVm.dispose();
    return super.close();
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
    on<ItemsUpdatedEvent>(_onItemsUpdatedEvent);
    on<SyncEvent>(_onSyncEvent);
    on<SearchEvent>(_onSearchEvent);
    on<ErrorEvent>(_onErrorEvent);
  }

  void _onInitialEvent(InitialEvent event, Emitter<AccsState> emit) {
    _itemsSubscription?.cancel();
    _itemsSubscription = _watchLoginItems.execute().listen(
      (items) => add(AccsEvent.itemsUpdated(items)),
      onError: (Object error) => add(AccsEvent.error(error)),
    );

    if (_isActive) {
      _triggerSync();
    }
  }

  void _onItemsUpdatedEvent(ItemsUpdatedEvent event, Emitter<AccsState> emit) {
    emit(
      AccsState.common(
        data: data.copyWith(
          items: event.items,
          filtered: _filter(event.items, data.searchString),
        ),
      ),
    );
  }

  void _onSyncEvent(SyncEvent event, Emitter<AccsState> emit) {
    _triggerSync();
  }

  void _onSearchEvent(SearchEvent event, Emitter<AccsState> emit) {
    emit(
      AccsState.common(
        data: data.copyWith(
          searchString: event.query,
          filtered: _filter(data.items, event.query),
        ),
      ),
    );
  }

  void _onErrorEvent(ErrorEvent event, Emitter<AccsState> emit) {
    if (data.items.isEmpty) {
      emit(AccsState.error(data: data, e: event.error));
    } else {
      log(
        'Accounts sync/watch error (ignored, list non-empty): ${event.error}',
        name: runtimeType.toString(),
      );
    }
  }

  void _triggerSync() {
    _syncSubscription?.cancel();
    _syncSubscription = _syncLoginItems.execute().listen((items) {
      log(
        'Accounts sync completed: ${items.length}',
        name: runtimeType.toString(),
      );
      // debugger();
    }, onError: (Object error) => add(AccsEvent.error(error)));
  }

  List<LoginItem> _filter(List<LoginItem> items, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return items;
    }
    return items.where((item) {
      return item.title.toLowerCase().contains(q) ||
          item.username.toLowerCase().contains(q) ||
          item.websiteUrl.toLowerCase().contains(q);
    }).toList();
  }
}
