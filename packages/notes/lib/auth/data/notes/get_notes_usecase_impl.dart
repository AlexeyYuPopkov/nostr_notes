import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/tag/tag.dart';
import 'package:nostr_notes/auth/data/notes_repository_impl.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/usecase/get_notes_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:rxdart/rxdart.dart';

class GetNotesUsecaseImpl with GetNotesFiltering implements GetNotesUsecase {
  // final NotesRepository _notesRepository;
  final SessionUsecase _sessionUsecase;
  final NoteCryptoUseCase _noteCryptoUseCase;
  final RawEventStore _eventStore;

  GetNotesUsecaseImpl({
    // required NotesRepository notesRepository,
    required SessionUsecase sessionUsecase,
    required NoteCryptoUseCase noteCryptoUseCase,
    required RawEventStore eventStore,
  }) : // _notesRepository = notesRepository,
       _sessionUsecase = sessionUsecase,
       _noteCryptoUseCase = noteCryptoUseCase,
       _eventStore = eventStore;

  @override
  Stream<List<Note>> execute() {
    final keys = _sessionUsecase.currentSession.keys;
    final publicKey = keys?.publicKey;

    if (publicKey == null || publicKey.isEmpty) {
      throw const AppError.notAuthenticated();
    }

    return _watchNotes(pubkey: publicKey).exhaustMap((items) {
      if (items.isEmpty) {
        return Stream.value(<Note>[]);
      }

      return Stream.fromFuture(_decryptNotes(items)).map((decryptedNotes) {
        return decryptedNotes.sorted(
          (a, b) => b.updatedAt.compareTo(a.updatedAt),
        );
      });
    });
  }

  @override
  Future<List<Note>> executeAsync({Set<String>? dTags}) async {
    final keys = _sessionUsecase.currentSession.keys;
    final publicKey = keys?.publicKey;

    if (publicKey == null || publicKey.isEmpty) {
      throw const AppError.notAuthenticated();
    }

    return _getNotes(pubkey: publicKey, dTags: dTags).then(
      (notes) => notes.sorted((a, b) => b.updatedAt.compareTo(a.updatedAt)),
    );
  }

  Stream<Iterable<Note>> _watchNotes({required String pubkey}) {
    return _eventStore
        .watchEvents(
          RawEventQuery(
            authors: [pubkey],
            kinds: [EventKind.note.value],
            tagFilters: [
              TagFilter(Tag.p.value, [pubkey]),
            ],
          ),
        )
        .asyncMap((items) async {
          final deleted = await _eventStore.queryEvents(
            RawEventQuery(authors: [pubkey], kinds: const [NostrKind.deletion]),
          );

          return performNotesFiltering(rawNotes: items, deleted: deleted);
        });
  }

  Future<Iterable<Note>> _getNotes({
    required String pubkey,
    Set<String>? dTags,
  }) async {
    final rawResult = await _eventStore.queryEvents(
      RawEventQuery(
        authors: [pubkey],
        kinds: [EventKind.note.value],
        // Each filter is a separate join, so these AND together.
        tagFilters: [
          TagFilter(Tag.p.value, [pubkey]),
          if (dTags != null) TagFilter(Tag.d.value, dTags.toList()),
        ],
      ),
    );

    final deleted = await _eventStore.queryEvents(
      RawEventQuery(authors: [pubkey], kinds: const [NostrKind.deletion]),
    );

    return performNotesFiltering(rawNotes: rawResult, deleted: deleted);
  }

  Future<Iterable<Note>> _decryptNotes(Iterable<Note> notes) async {
    final decryptedNotes = <Note>[];

    for (final note in notes) {
      try {
        final decryptedNote = await _noteCryptoUseCase.decryptNote(note);
        decryptedNotes.add(decryptedNote);
      } catch (e, s) {
        log('Failed to decrypt note ${note.dTag}: $e', stackTrace: s);
        decryptedNotes.add(note.copyWith(error: e));
      }
    }

    return decryptedNotes;
  }
}
