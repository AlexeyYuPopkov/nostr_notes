import 'dart:async';
import 'dart:developer';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:common/domain/error/app_error.dart';
import 'package:common/presentation/tools/section_scroll_vm.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/l10n/app_localizations.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/usecase/create_note_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/delete_note_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/fetch_notes_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_notes_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_pending_usecase.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes/bloc/pending_vm.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';
import 'package:nostr_notes/services/outbox_publisher.dart';
import 'package:rxdart/transformers.dart';

import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_command.dart';
import 'notes_list_data.dart';
import 'notes_list_event.dart';
import 'notes_list_state.dart';

final class NotesListBloc extends Bloc<NotesListEvent, NotesListState> {
  static const debounceGuard = Duration(milliseconds: 200);
  DiStorage get _di => DiStorage.shared;
  NotesListData get data => state.data;

  final AppLocalizations l10n;
  final DashboardBloc _dashboardBloc;

  late final FetchNotesUsecase _fetchNotesUsecase = _di.resolve();
  late final GetNotesUsecase _getNotesUsecase = _di.resolve();
  late final pendingVm = PendingVm(
    getPendingUsecase: _di.resolve<GetPendingUsecase>(),
  );
  late final DeleteNoteUsecase _deleteNoteUsecase = _di.resolve();
  late final OutboxPublisher _outbox = _di.resolve();
  late final CreateNoteUsecase _createNoteUsecase = _di.resolve();

  final SectionScrollVm<NotesListHeader> sectionScrollVm;

  StreamSubscription? _fetchNotesSubscription;
  StreamSubscription? _getNotesSubscription;
  StreamSubscription? _dashboardTabSubscription;
  StreamSubscription<DashboardCommand>? _dashboardCommandSubscription;

  NotesListBloc({required this.l10n, required DashboardBloc dashboardBloc})
    : _dashboardBloc = dashboardBloc,
      sectionScrollVm = SectionScrollVm<NotesListHeader>(
        scrollController: dashboardBloc.headerVm.scrollController,
      ),
      super(NotesListState.loading(data: NotesListData.initial())) {
    _setupHandlers();
    _subscribeToDashboard();

    add(const NotesListEvent.initial());
  }

  @override
  Future<void> close() {
    sectionScrollVm.dispose();

    _fetchNotesSubscription?.cancel();
    _fetchNotesSubscription = null;
    _getNotesSubscription?.cancel();
    _getNotesSubscription = null;
    _dashboardTabSubscription?.cancel();
    _dashboardTabSubscription = null;
    _dashboardCommandSubscription?.cancel();
    _dashboardCommandSubscription = null;
    pendingVm.dispose();
    return super.close();
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
    on<GetNotesEvent>(
      _onGetNotesEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceGuard).switchMap(mapper),
    );
    on<ErrorEvent>(
      _onErrorEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceGuard).switchMap(mapper),
    );
    on<DeleteNoteEvent>(
      _onDeleteNoteEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceGuard).switchMap(mapper),
    );
    on<RefreshEvent>(
      _onRefreshEvent,
      transformer: (events, mapper) =>
          events.throttleTime(debounceGuard).switchMap(mapper),
    );

    on<AssignLabelsEvent>(
      _onAssignLabelsEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceGuard).switchMap(mapper),
    );
    on<SearchNotesEvent>(
      _onSearchNotes,
      transformer: (events, mapper) => restartable<SearchNotesEvent>()(
        events.debounceTime(const Duration(milliseconds: 300)),
        mapper,
      ),
    );
    on<SetFolderFilterEvent>(
      _onSetFolderFilterEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceGuard).switchMap(mapper),
    );
  }

  /// Folder → note-count, for populating the filter picker. Excludes
  /// [CategoryType.other] — the fallback label isn't a real, pickable
  /// folder (matches the per-note labels picker's category list).
  Map<CategoryType, int> get folderCounts {
    final counts = <CategoryType, int>{};
    for (final note in data.allNotes) {
      for (final label in note.labels.whereType<Label>()) {
        if (label.type == CategoryType.other) continue;
        counts[label.type] = (counts[label.type] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Reacts to dashboard-wide signals: clears an active search whenever the
  /// selected tab changes (any destination — not just Folders, matching the
  /// pre-extraction behavior), and re-syncs on refresh / app-resume
  /// commands broadcast from [DashboardBloc].
  void _subscribeToDashboard() {
    _dashboardTabSubscription = _dashboardBloc.stream
        .map((state) => state.data.tab)
        .distinct()
        .listen((_) {
          if (data.searchString.trim().isNotEmpty) {
            add(const NotesListEvent.search(''));
          }
        });

    _dashboardCommandSubscription = _dashboardBloc.commands.listen((command) {
      switch (command) {
        case DashboardCommand.refresh:
          add(const NotesListEvent.refresh());
        case DashboardCommand.resumed:
          add(const InitialEvent(showShimmers: false));
      }
    });
  }

  void _setupSubscription() {
    _fetchNotesSubscription?.cancel();
    _fetchNotesSubscription = _fetchNotesUsecase
        .execute(const FetchNotesUsecaseParams.userNotes())
        .doOnData((data) {
          log(
            'FetchNotesUsecase emitted data with length: ${data.length}',
            name: runtimeType.toString(),
          );
        })
        .listen(
          (_) {},
          onError: (error) {
            add(NotesListEvent.error(error: error));
          },
        );

    _getNotesSubscription?.cancel();
    _getNotesSubscription = _getNotesUsecase
        .execute()
        .throttleTime(Durations.medium2, trailing: true)
        .listen(
          (items) {
            add(NotesListEvent.getNotes(notes: items));
          },
          onError: (error) {
            add(NotesListEvent.error(error: error));
          },
        );

    // Relay hiccups are normal in a decentralized system — surfaced via the
    // small always-visible RelayStatusIndicator in the AppBar (which reads
    // RelaysMonitoringUsecase directly, not through this bloc), not as
    // a ScaffoldMessenger toast anymore.

    pendingVm.subscribe();
  }

  void _onInitialEvent(InitialEvent event, Emitter<NotesListState> emit) async {
    if (event.showShimmers) {
      if (state is! LoadingState) {
        emit(NotesListState.loading(data: data));
      }
      await Future.delayed(const Duration(milliseconds: 500));
    } else if (state is! CommonState) {
      emit(NotesListState.common(data: data));
    }

    _setupSubscription();
    if (!event.showShimmers) {
      _dashboardBloc.refreshButtonVm.isRefreshing = false;
      return;
    }

    await Future.delayed(const Duration(seconds: 3));

    if (state is LoadingState && isClosed == false) {
      emit(NotesListState.common(data: data));
      _dashboardBloc.refreshButtonVm.isRefreshing = false;
    }
  }

  void _onGetNotesEvent(
    GetNotesEvent event,
    Emitter<NotesListState> emit,
  ) async {
    try {
      if (isClosed) {
        return;
      }

      final (filtered, sections) = await _recompute(
        event.notes,
        query: data.searchString,
        folders: data.folderFilter,
      );

      if (isClosed) {
        return;
      }

      final hasDecryptionErrors = event.notes.any((n) => n.error != null);

      if (hasDecryptionErrors) {
        final notesLength = event.notes.length;
        final errorCount = event.notes.where((n) => n.error != null).length;
        log(
          'Decryption errors: $errorCount / $notesLength notes — '
          'possibly a wrong PIN.',
          name: runtimeType.toString(),
        );
        _dashboardBloc.reportDecryptFailure(
          failedCount: errorCount,
          totalCount: notesLength,
        );
        emit(
          NotesListState.error(
            e: SomeNotesWasNotDecrypted(
              failedCount: errorCount,
              totalCount: notesLength,
            ),
            data: data.copyWith(
              allNotes: event.notes,
              filtered: filtered,
              sections: sections,
            ),
          ),
        );
      } else {
        emit(
          NotesListState.common(
            data: data.copyWith(
              allNotes: event.notes,
              filtered: filtered,
              sections: sections,
            ),
          ),
        );
      }
    } catch (e) {
      if (isClosed) {
        return;
      }
      emit(NotesListState.error(e: e, data: data));
    } finally {
      _dashboardBloc.refreshButtonVm.isRefreshing = false;
    }
  }

  void _onErrorEvent(ErrorEvent event, Emitter<NotesListState> emit) {
    emit(NotesListState.error(data: data, e: event.error));
  }

  void _onDeleteNoteEvent(
    DeleteNoteEvent event,
    Emitter<NotesListState> emit,
  ) async {
    try {
      await _deleteNoteUsecase.execute(note: event.note);
    } catch (e) {
      emit(NotesListState.error(e: e, data: data));
    }
  }

  void _onAssignLabelsEvent(
    AssignLabelsEvent event,
    Emitter<NotesListState> emit,
  ) async {
    try {
      final labels = event.labels.map(Label.fromCategoryType).toList();
      await _createNoteUsecase.assignLabels(note: event.note, labels: labels);
    } catch (e) {
      emit(NotesListState.error(e: e, data: data));
    }
  }

  void _onRefreshEvent(RefreshEvent event, Emitter<NotesListState> emit) {
    _outbox.refresh();
    add(const NotesListEvent.initial());
  }

  Future<void> _onSearchNotes(
    SearchNotesEvent event,
    Emitter<NotesListState> emit,
  ) async {
    if (isClosed) {
      return;
    }

    final query = event.query;
    final (filtered, sections) = await _recompute(
      data.allNotes,
      query: query,
      folders: data.folderFilter,
    );

    emit(
      NotesListState.common(
        data: data.copyWith(
          searchString: query,
          filtered: filtered,
          sections: sections,
        ),
      ),
    );
  }

  Future<void> _onSetFolderFilterEvent(
    SetFolderFilterEvent event,
    Emitter<NotesListState> emit,
  ) async {
    if (isClosed) {
      return;
    }

    final folders = event.folders;
    final (filtered, sections) = await _recompute(
      data.allNotes,
      query: data.searchString,
      folders: folders,
    );

    emit(
      NotesListState.common(
        data: data.copyWith(
          folderFilter: folders,
          filtered: filtered,
          sections: sections,
        ),
      ),
    );
  }

  /// Applies the folder filter and text search (in that order) to [notes],
  /// then groups whichever set ends up visible into date sections. Shared by
  /// every handler that can change what's visible — new notes arriving,
  /// typing a search query, or changing the folder filter — so they can't
  /// drift out of sync with each other.
  Future<(List<Note>, List<NotesListSection>)> _recompute(
    List<Note> notes, {
    required String query,
    required Set<CategoryType> folders,
  }) async {
    final byFolder = _filterByFolders(notes, folders);
    final filtered = await _filterNotes(byFolder, query);
    final isFiltering = query.trim().isNotEmpty || folders.isNotEmpty;
    final visibleNotes = isFiltering ? filtered : notes;
    final sections = await NotesListSection.groupNotesByDate(
      notes: visibleNotes,
      l10n: l10n,
    );
    return (filtered, sections);
  }

  /// Notes carrying a label for any folder in [folders] (OR semantics).
  /// Empty [folders] means no filter — every note passes through.
  List<Note> _filterByFolders(List<Note> notes, Set<CategoryType> folders) {
    if (folders.isEmpty) {
      return notes;
    }
    return notes
        .where(
          (note) => note.labels.whereType<Label>().any(
            (label) => folders.contains(label.type),
          ),
        )
        .toList();
  }

  /// Case-insensitive substring match over each note's content, summary and
  /// label values. Notes are already decrypted in [NotesListData.allNotes], so
  /// this is a pure in-memory filter — no DB access, no plaintext index.
  Future<List<Note>> _filterNotes(List<Note> notes, String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return notes;
    }
    return notes.where((note) {
      if (note.summary.toLowerCase().contains(q)) return true;
      if (note.content.toLowerCase().contains(q)) return true;
      for (final label in note.labels) {
        if (label.textValue.toLowerCase().contains(q)) return true;
      }
      return false;
    }).toList();
  }
}

final class SomeNotesWasNotDecrypted extends AppError {
  final int failedCount;
  final int totalCount;

  const SomeNotesWasNotDecrypted({
    required this.failedCount,
    required this.totalCount,
    super.parentError,
    super.reason,
  });
}
