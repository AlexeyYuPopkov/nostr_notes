import 'dart:async';

import 'package:common/presentation/buttons/refresh_button/refresh_button.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/repo/notes_list_tab_repo.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes_list_tab.dart';
import 'package:common/domain/repo/app_lifecycle_listener_repository.dart';

import 'package:rxdart/rxdart.dart';

import '../header/note_list_header.dart';
import 'dashboard_command.dart';
import 'dashboard_data.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

final class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  static const debounceGuard = Duration(milliseconds: 200);
  DiStorage get _di => DiStorage.shared;

  DashboardData get data => state.data;
  late final NotesListTabRepo _tabRepo = _di.resolve();
  late final AppLifecycleListenerRepository _appLifecycleListener = _di
      .resolve();

  late final headerVm = NoteListHeaderVm();

  late final refreshButtonVm = RefreshButtonVm(
    onRefresh: () => add(const DashboardEvent.refresh()),
  );

  /// Gates the wrong-PIN dialog to at most once per screen instance,
  /// regardless of which tab detects the decrypt failure first — every tab
  /// decrypts with the same session key.
  late final wrongPinDialogShown = ValueNotifier<bool>(false);

  final _commands = StreamController<DashboardCommand>.broadcast();

  /// One-shot commands (refresh tapped / app resumed) for child blocs to
  /// react to. Children subscribe in their constructor and cancel in
  /// `close()`.
  Stream<DashboardCommand> get commands => _commands.stream;

  final _decryptFailures = StreamController<DecryptFailureReport>.broadcast();

  /// Emits at most once per [wrongPinDialogShown] gate; the widget layer
  /// listens to show the shared decrypt-failed dialog.
  Stream<DecryptFailureReport> get decryptFailures => _decryptFailures.stream;

  StreamSubscription? _lifecycleSubscription;

  DashboardBloc()
    : super(DashboardState.common(data: DashboardData.initial())) {
    _setupHandlers();

    _lifecycleSubscription = _appLifecycleListener.isActiveStream
        .distinct()
        .where((isActive) => isActive)
        .listen((_) => _commands.add(DashboardCommand.resumed));

    add(const DashboardEvent.initial());
  }

  /// Reports a decrypt failure detected by a tab. Shows the shared dialog at
  /// most once per screen instance; later reports (from the same or another
  /// tab) stay silent.
  void reportDecryptFailure({
    required int failedCount,
    required int totalCount,
  }) {
    if (wrongPinDialogShown.value) {
      return;
    }
    wrongPinDialogShown.value = true;
    _decryptFailures.add(
      DecryptFailureReport(failedCount: failedCount, totalCount: totalCount),
    );
  }

  @override
  Future<void> close() async {
    await _lifecycleSubscription?.cancel();
    await _commands.close();
    await _decryptFailures.close();
    headerVm.dispose();

    wrongPinDialogShown.dispose();
    await super.close();
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
    on<SelectTabEvent>(
      _onSelectTabEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceGuard).switchMap(mapper),
    );
    on<RefreshEvent>(
      _onRefreshEvent,
      transformer: (events, mapper) =>
          events.throttleTime(debounceGuard).switchMap(mapper),
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

  void _onSelectTabEvent(SelectTabEvent event, Emitter<DashboardState> emit) {
    if (isClosed) {
      return;
    }

    _tabRepo.setTabIndex(event.tab.index);
    emit(DashboardState.common(data: data.copyWith(tab: event.tab)));
  }

  void _onRefreshEvent(RefreshEvent event, Emitter<DashboardState> emit) {
    _commands.add(DashboardCommand.refresh);
  }
}

/// A decrypt failure reported by a tab; see
/// [DashboardBloc.reportDecryptFailure].
final class DecryptFailureReport {
  final int failedCount;
  final int totalCount;

  const DecryptFailureReport({
    required this.failedCount,
    required this.totalCount,
  });
}
