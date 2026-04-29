import 'dart:developer';
import 'dart:io';

import 'package:nostr_notes/auth/domain/repo/notes_repository.dart';
import 'package:nostr_notes/auth/domain/repo/relays_list_repo.dart';
import 'package:common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:rxdart/transformers.dart';

class FetchNotesUsecase {
  final NotesRepository _notesRepository;
  final SessionUsecase _sessionUsecase;
  final RelaysListRepo _relaysListRepo;
  final Now _now;

  FetchNotesUsecase({
    required NotesRepository notesRepository,
    required SessionUsecase sessionUsecase,
    required RelaysListRepo relaysListRepo,
    Now now = const Now(),
  }) : _notesRepository = notesRepository,
       _sessionUsecase = sessionUsecase,
       _relaysListRepo = relaysListRepo,
       _now = now;

  Stream<List<dynamic>> execute(FetchNotesUsecaseParams params) {
    return switch (params) {
      UserNotes() => _currentUserNotes(params),
      NoteWithId(:final id) => _noteWithId(NoteWithId(id: id)),
    };
  }

  Stream<List<dynamic>> _currentUserNotes(UserNotes params) {
    final publicKey = _sessionUsecase.currentSession.keys?.publicKey;
    if (publicKey == null || publicKey.isEmpty) {
      throw const AppError.notAuthenticated();
    }

    return _relaysListRepo.relaysListStream.switchMap((relays) {
      _notesRepository.syncRelays(relays);
      _notesRepository.sendNotesRequest(
        pubkey: publicKey,
        relays: relays,
        until: _now.now(),
      );

      return _notesRepository.eventsStream.doOnError((error, stackTrace) {
        log(
          'Error in FetchNotesUsecase: $error',
          name: runtimeType.toString(),
          error: error,
          stackTrace: stackTrace,
        );

        if (error is SocketException || error is WebSocketException) {
          throw FetchNotesUsecaseNetworkError(parentError: error);
        }
      });
    });
  }

  Stream<List<dynamic>> _noteWithId(NoteWithId params) {
    final relays = _relaysListRepo.getRelaysList();

    Future.microtask(() {
      _notesRepository.sendNoteRequest(
        id: params.id,
        relays: relays.toSet(),
        until: _now.now(),
      );
    });

    return _notesRepository.eventsStream
        .doOnData((e) {
          log(
            'Received events in FetchNotesUsecase: ${e.length} events',
            name: runtimeType.toString(),
          );
        })
        .where((events) {
          return events.any((event) => event.id == params.id);
        })
        .doOnData((events) {
          log(
            'Emitting events in FetchNotesUsecase: ${events.length} events',
            name: runtimeType.toString(),
          );
        })
        .doOnError((error, stackTrace) {
          log(
            'Error in FetchNotesUsecase: $error',
            name: runtimeType.toString(),
            error: error,
            stackTrace: stackTrace,
          );

          if (error is SocketException || error is WebSocketException) {
            throw FetchNotesUsecaseNetworkError(parentError: error);
          }
        });
  }

  Stream<NotesRepositoryRelayError> get relayErrors =>
      _notesRepository.relayErrors;
}

final class FetchNotesUsecaseNetworkError extends AppError {
  @override
  String get message => 'Failed to fetch notes due to network error.';
  const FetchNotesUsecaseNetworkError({super.parentError})
    : super(reason: 'Network error while fetching notes');
}

sealed class FetchNotesUsecaseParams {
  const FetchNotesUsecaseParams();

  const factory FetchNotesUsecaseParams.userNotes() = UserNotes;
  const factory FetchNotesUsecaseParams.noteWithId({required String id}) =
      NoteWithId;
}

final class UserNotes extends FetchNotesUsecaseParams {
  const UserNotes();
}

final class NoteWithId extends FetchNotesUsecaseParams {
  final String id;
  const NoteWithId({required this.id});
}
