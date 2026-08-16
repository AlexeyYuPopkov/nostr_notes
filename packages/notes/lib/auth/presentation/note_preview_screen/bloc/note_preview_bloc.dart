import 'dart:async';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/nip44_exception.dart';
import 'package:nostr_notes/auth/domain/usecase/create_note_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/export_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/fetch_notes_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_note_usecase.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/bloc/note_preview_data.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/bloc/note_preview_event.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/bloc/note_preview_state.dart';
import 'package:common/domain/repo/app_lifecycle_listener_repository.dart';
import 'package:common/presentation/buttons/refresh_button/refresh_button.dart';
import 'package:common/presentation/tools/optional_box.dart';
import 'package:nostr_notes/common/domain/usecase/verification_usecase.dart';
import 'package:nostr_notes/services/ads/ads_service.dart';
import 'package:nostr_notes/services/outbox_publisher.dart';
import 'package:rxdart/rxdart.dart';

final class NotePreviewBloc extends Bloc<NotePreviewEvent, NotePreviewState> {
  static const debounceGuard = Duration(milliseconds: 200);
  final PathParams pathParams;
  NotePreviewData get data => state.data;
  DiStorage get _di => DiStorage.shared;
  late final FetchNotesUsecase _fetchNotesUsecase = _di.resolve();
  late final GetNoteUsecase _getNoteUsecase = _di.resolve();
  late final CreateNoteUsecase _createNoteUsecase = _di.resolve();
  late final ExportUsecase _exportUsecase = _di.resolve();
  late final OutboxPublisher _outbox = _di.resolve();
  late final AppLifecycleListenerRepository _appLifecycleListener = _di
      .resolve();
  late final VerificationUsecase _verificationUsecase = _di.resolve();
  late final AdsService _adsService = _di.resolve();
  StreamSubscription? _getNoteSubscription;
  StreamSubscription? _fetchNoteSubscription;
  StreamSubscription? _lifecycleSubscription;

  late final refreshButtonVm = RefreshButtonVm(
    onRefresh: () => add(const NotePreviewEvent.refresh()),
  );

  NotePreviewBloc({required this.pathParams})
    : super(NotePreviewState.loading(data: NotePreviewData.initial())) {
    _setupHandlers();

    add(const NotePreviewEvent.initial());
  }

  @override
  Future<void> close() {
    _getNoteSubscription?.cancel();
    _getNoteSubscription = null;
    _fetchNoteSubscription?.cancel();
    _fetchNoteSubscription = null;
    _lifecycleSubscription?.cancel();
    _lifecycleSubscription = null;
    return super.close();
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
    on<ErrorEvent>(
      _onErrorEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceGuard).switchMap(mapper),
    );
    on<NoteUpdatedEvent>(
      _onNoteUpdatedEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceGuard).switchMap(mapper),
    );

    on<RefreshEvent>(
      _onRefreshEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceGuard).switchMap(mapper),
    );

    on<AssignLabelsEvent>(_onAssignLabelsEvent);
    on<WillExportNoteEvent>(
      _onWillExportNoteEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceGuard).switchMap(mapper),
    );
    on<ExportNoteEvent>(_onExportNoteEvent);
  }

  void _setupSubscriptions() {
    _fetchNoteSubscription?.cancel();
    _fetchNoteSubscription = null;

    _fetchNoteSubscription = _fetchNotesUsecase
        .execute(FetchNotesUsecaseParams.noteWithId(id: pathParams.id))
        .listen((_) {}, onError: (e) => add(NotePreviewEvent.error(error: e)));

    _getNoteSubscription?.cancel();
    _getNoteSubscription = null;
    _getNoteSubscription = _getNoteUsecase.watch(pathParams.id).listen((note) {
      add(NotePreviewEvent.noteUpdated(note));
    }, onError: (e) => add(NotePreviewEvent.error(error: e)));

    _lifecycleSubscription ??= _appLifecycleListener.isActiveStream
        .distinct()
        .where((isActive) => isActive)
        .listen((_) {
          add(const NotePreviewEvent.refresh());
        });
  }

  void _onInitialEvent(
    InitialEvent event,
    Emitter<NotePreviewState> emit,
  ) async {
    _setupSubscriptions();
  }

  void _onErrorEvent(ErrorEvent event, Emitter<NotePreviewState> emit) {
    final error = event.error;

    if (error is Nip44Exception) {
      emit(NotePreviewState.cannotDecrypt(data: data));
    } else {
      emit(NotePreviewState.error(data: data, error: event.error));
    }
  }

  void _onNoteUpdatedEvent(
    NoteUpdatedEvent event,
    Emitter<NotePreviewState> emit,
  ) async {
    final note = event.note;
    emit(NotePreviewState.common(data: data.copyWith(note: OptionalBox(note))));

    // if (_classificationResult.isEmpty) {
    //   try {
    //     final classification = await _calculateClassificationUsecase.execute(
    //       note,
    //       useCorrection: true,
    //     );

    //     _classificationResult
    //       ..clear()
    //       ..addAll(classification);

    //     log(
    //       'Classification: ${(classification..removeWhere((_, val) => val < 0.2)).toString()}',
    //       name: 'Classification',
    //     );
    //   } catch (e) {
    //     log('Error during classification: $e', name: 'Classification');
    //   }
    // }
    Future.delayed(
      Durations.short1,
      () => refreshButtonVm.isRefreshing = false,
    );
  }

  void _onRefreshEvent(RefreshEvent event, Emitter<NotePreviewState> emit) {
    _outbox.refresh();
    _setupSubscriptions();
  }

  void _onAssignLabelsEvent(
    AssignLabelsEvent event,
    Emitter<NotePreviewState> emit,
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
      emit(NotePreviewState.error(error: e, data: data));
    }
  }

  Future<void> _onWillExportNoteEvent(
    WillExportNoteEvent event,
    Emitter<NotePreviewState> emit,
  ) async {
    if (AppConfig.showAds) {
      _verificationUsecase.skipNextVerification();
      await _adsService.showInterstitial();
    }
    emit(NotePreviewState.willExportNote(data: data));
  }

  Future<void> _onExportNoteEvent(
    ExportNoteEvent event,
    Emitter<NotePreviewState> emit,
  ) async {
    emit(NotePreviewState.loading(data: data));
    try {
      final (filePath, bytes, fileName) = await _exportUsecase.exportNotes(
        params: ExportParamsIds(
          password: event.password,
          fileName: event.fileName,
          noteIds: [pathParams.id],
        ),
      );
      if (bytes.isEmpty) {
        emit(
          NotePreviewState.error(
            data: data,
            error: const ExportError(payload: ExportErrorType.noNotes),
          ),
        );
        return;
      }

      emit(NotePreviewState.loading(data: data, progress: 0.9));
      await Future.delayed(const Duration(milliseconds: 700));

      emit(
        NotePreviewState.exportSuccess(
          data: data,
          filePath: filePath,
          bytes: bytes,
          fileName: fileName,
        ),
      );
    } catch (e) {
      emit(NotePreviewState.error(data: data, error: e));
    }
  }
}
