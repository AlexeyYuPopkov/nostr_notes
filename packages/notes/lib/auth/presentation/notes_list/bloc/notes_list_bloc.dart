import 'dart:async';
import 'dart:developer';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:common/domain/error/app_error.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/repo/notes_list_tab_repo.dart';
import 'package:nostr_notes/auth/presentation/notes_list/tabs/folders_tab_content.dart';
import 'package:nostr_notes/common/domain/repository/app_lifecycle_listener_repository.dart';
import 'package:nostr_notes/l10n/app_localizations.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/usecase/create_note_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/delete_note_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/fetch_notes_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_notes_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_pending_usecase.dart';
import 'package:nostr_notes/auth/presentation/notes_list/bloc/pending_vm.dart';
import 'package:common/presentation/buttons/refresh_button/refresh_button.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';
import 'package:nostr_notes/services/outbox_publisher.dart';
import 'package:rxdart/transformers.dart';

import 'notes_list_data.dart';
import 'notes_list_event.dart';
import 'notes_list_state.dart';
import '../tabs/notes_list_tab.dart';

final class NotesListBloc extends Bloc<NotesListEvent, NotesListState> {
  static const errorStreamDebounce = Duration(milliseconds: 500);
  static const debounceGuard = Duration(milliseconds: 200);
  DiStorage get _di => DiStorage.shared;
  NotesListData get data => state.data;

  final AppLocalizations l10n;

  late final refreshButtonVm = RefreshButtonVm(
    onRefresh: () {
      add(const NotesListEvent.refresh());
    },
  );

  late final FetchNotesUsecase _fetchNotesUsecase = _di.resolve();
  late final GetNotesUsecase _getNotesUsecase = _di.resolve();
  late final pendingVm = PendingVm(
    getPendingUsecase: _di.resolve<GetPendingUsecase>(),
  );
  late final DeleteNoteUsecase _deleteNoteUsecase = _di.resolve();
  late final OutboxPublisher _outbox = _di.resolve();
  late final CreateNoteUsecase _createNoteUsecase = _di.resolve();

  late final foldersVm = FoldersTabContentVM.fromNotes([], null, l10n);
  late final NotesListTabRepo _tabRepo = _di.resolve();

  late final AppLifecycleListenerRepository appLifecycleListener = _di
      .resolve();

  StreamSubscription? _fetchNotesSubscription;
  StreamSubscription? _getNotesSubscription;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _lifecycleSubscription;

  NotesListBloc({required this.l10n})
    : super(NotesListState.loading(data: NotesListData.initial())) {
    _setupHandlers();

    add(const NotesListEvent.initial());
  }

  @override
  Future<void> close() {
    _fetchNotesSubscription?.cancel();
    _fetchNotesSubscription = null;
    _getNotesSubscription?.cancel();
    _getNotesSubscription = null;
    _errorSubscription?.cancel();
    _errorSubscription = null;
    _lifecycleSubscription?.cancel();
    _lifecycleSubscription = null;
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
    on<SelectFolderEvent>(
      _onSelectFolderEvent,
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
            // final _debug =
            //     {
            //       'My Passwords': DateTime(2026, 3, 18, 12, 30),
            //       'My Nsecs': DateTime(2026, 3, 15, 13),
            //       'App Ideas': DateTime(2026, 3, 15, 12),

            //       'Travel Plans': DateTime(2026, 2, 23),
            //       'Quick Notes': DateTime(2026, 2, 20),
            //       'Reading List': DateTime(2026, 2, 17),

            //       'Developer Setup': DateTime(2026, 1, 19),
            //       'Security Notes': DateTime(2026, 1, 10),
            //       'Daily Journal': DateTime(2026, 1, 5),
            //       'Atomic Habits': DateTime(2026, 1, 4),
            //     }.map(
            //       (k, v) =>
            //           MapEntry(k.toLowerCase(), v.add(Duration(days: 12))),
            //     );

            add(
              NotesListEvent.getNotes(
                notes: items,
                // notes: items
                //     .mapIndexed((index, e) {
                //       final key = _debug.keys
                //           .where(
                //             (k) => e.summary.toLowerCase().contains(
                //               k.toLowerCase(),
                //             ),
                //           )
                //           .firstOrNull;
                //       return e.copyWith(createdAt: _debug[key]!);
                //       // } else {
                //       //   return e;
                //       // }
                //     })
                //     .sorted((a, b) => b.createdAt.compareTo(a.createdAt)),
              ),
            );
          },
          onError: (error) {
            add(NotesListEvent.error(error: error));
          },
        );

    _errorSubscription?.cancel();
    _errorSubscription = _fetchNotesUsecase.relayErrors
        .debounceTime(errorStreamDebounce)
        .listen((error) {
          add(NotesListEvent.error(error: error));
        });

    _lifecycleSubscription ??= appLifecycleListener.isActiveStream
        .distinct()
        .where((isActive) => isActive)
        .listen((_) {
          add(const InitialEvent(showShimmers: false));
        });

    pendingVm.subscribe();
  }

  void _onInitialEvent(InitialEvent event, Emitter<NotesListState> emit) async {
    final savedTabIndex = _tabRepo.getTabIndex();
    final savedTab =
        NotesListTab.tabs.elementAtOrNull(savedTabIndex) ??
        NotesListTab.tabs.first;

    final nextData = data.copyWith(tab: savedTab);

    if (event.showShimmers) {
      if (state is! LoadingState) {
        emit(NotesListState.loading(data: nextData));
      }
      await Future.delayed(const Duration(milliseconds: 500));
    } else if (state is! CommonState) {
      emit(NotesListState.common(data: nextData));
    }

    _setupSubscription();
    if (!event.showShimmers) {
      refreshButtonVm.isRefreshing = false;
      return;
    }

    await Future.delayed(const Duration(seconds: 3));

    if (state is LoadingState && isClosed == false) {
      emit(NotesListState.common(data: data));
      refreshButtonVm.isRefreshing = false;
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

      foldersVm.setNotes(event.notes, l10n);

      final filtered = await _filterNotes(event.notes, data.searchString);
      final visibleNotes = data.searchString.trim().isEmpty
          ? event.notes
          : filtered;
      final sections = await NotesListSection.groupNotesByDate(
        notes: visibleNotes,
        l10n: l10n,
      );

      if (isClosed) {
        return;
      }

      final hasDecryptionErrors = event.notes.any((n) => n.error != null);

      if (hasDecryptionErrors) {
        final errorCount = event.notes.where((n) => n.error != null).length;
        log(
          'Decryption errors: $errorCount / ${event.notes.length} notes. '
          '${errorCount == event.notes.length ? 'All notes failed — likely wrong PIN.' : 'Some notes failed.'}',
          name: runtimeType.toString(),
        );
        emit(
          NotesListState.error(
            e: const SomeNotesWasNotDecrypted(),
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
      refreshButtonVm.isRefreshing = false;
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
      await _createNoteUsecase.assignLabels(
        note: event.note,
        // content: event.note.content,
        // dTag: event.note.dTag,
        // updatedAt: event.note.updatedAt,
        labels: labels,
      );
    } catch (e) {
      emit(NotesListState.error(e: e, data: data));
    }
  }

  void _onRefreshEvent(RefreshEvent event, Emitter<NotesListState> emit) {
    _outbox.refresh();
    add(const NotesListEvent.initial());
  }

  void _onSelectFolderEvent(
    SelectFolderEvent event,
    Emitter<NotesListState> emit,
  ) {
    if (isClosed) {
      return;
    }

    _tabRepo.setTabIndex(event.tab.index);
    emit(NotesListState.common(data: data.copyWith(tab: event.tab)));

    // Leaving with an active search → reset it so returning to "All" starts
    // clean. Reuses the (restartable, async-safe) search handler to rebuild
    // sections from the full set.
    if (data.searchString.trim().isNotEmpty) {
      add(const NotesListEvent.search(''));
    }
  }

  Future<void> _onSearchNotes(
    SearchNotesEvent event,
    Emitter<NotesListState> emit,
  ) async {
    if (isClosed) {
      return;
    }

    final query = event.query;
    final filtered = await _filterNotes(data.allNotes, query);
    final visibleNotes = query.trim().isEmpty ? data.allNotes : filtered;
    final sections = await NotesListSection.groupNotesByDate(
      notes: visibleNotes,
      l10n: l10n,
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
  const SomeNotesWasNotDecrypted({super.parentError, super.reason});
}
