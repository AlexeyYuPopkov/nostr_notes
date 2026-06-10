import 'dart:async';
import 'dart:developer';
import 'package:common/domain/error/app_error.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/repo/notes_list_tab_repo.dart';
import 'package:nostr_notes/auth/presentation/notes_list/tabs/folders_tab_content.dart';
import 'package:nostr_notes/common/domain/repository/app_lifecycle_listener_repository.dart';
import 'package:nostr_notes/l10n/app_localizations.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
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
    on<GetNotesEvent>(_onGetNotesEvent);
    on<ErrorEvent>(_onErrorEvent);
    on<DeleteNoteEvent>(_onDeleteNoteEvent);
    on<RefreshEvent>(
      _onRefreshEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceGuard).switchMap(mapper),
    );

    on<AssignLabelsEvent>(_onAssignLabelsEvent);
    on<SelectFolderEvent>(
      _onSelectFolderEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceGuard).switchMap(mapper),
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
        .debounceTime(Durations.medium2)
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
      emit(NotesListState.loading(data: nextData));
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

      final sections = NotesListSection.groupNotesByDate(
        notes: event.notes,
        l10n: l10n,
      );

      final decryptionErrorCount = event.notes
          .where((n) => n.error != null)
          .length;

      if (decryptionErrorCount > 0) {
        log(
          'Decryption errors: $decryptionErrorCount / ${event.notes.length} notes. '
          '${decryptionErrorCount == event.notes.length ? 'All notes failed — likely wrong PIN.' : 'Some notes failed.'}',
          name: runtimeType.toString(),
        );
      }

      if (decryptionErrorCount > 0) {
        emit(
          NotesListState.error(
            e: const SomeNotesWasNotDecrypted(),
            data: data.copyWith(
              notes: event.notes,
              sections: sections,
              decryptionErrorCount: decryptionErrorCount,
            ),
          ),
        );
      } else {
        emit(
          NotesListState.common(
            data: data.copyWith(
              notes: event.notes,
              sections: sections,
              decryptionErrorCount: decryptionErrorCount,
            ),
          ),
        );
      }
    } catch (e) {
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
  }
}

final class SomeNotesWasNotDecrypted extends AppError {
  const SomeNotesWasNotDecrypted({super.parentError, super.reason});
}
