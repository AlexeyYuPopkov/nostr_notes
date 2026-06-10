import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:common/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:cryptography/cryptography.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/tag/tag.dart';
import 'package:nostr/nostr_client/nostr_event_creator.dart';
import 'package:nostr_notes/auth/data/export_usecase_impl.dart';
import 'package:nostr_notes/auth/data/mappers/note_mapper.dart';
import 'package:nostr_notes/auth/data/models/backup_payload.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/usecase/crerate_summary_helper.dart';
import 'package:nostr_notes/auth/domain/usecase/import_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:nostr_notes/services/hex_to_bytes.dart';

const _kPbkdf2Iterations = 600000;

final class ImportUsecaseImpl implements ImportUsecase {
  final RawEventStore _eventStore;
  final NoteCryptoUseCase _noteCryptoUseCase;
  final SessionUsecase _sessionUsecase;
  final OutboxDaoInterface _outboxDao;
  final NostrEventCreator _eventCreator;
  final Now _now;

  const ImportUsecaseImpl({
    required RawEventStore eventStore,
    required NoteCryptoUseCase noteCryptoUseCase,
    required SessionUsecase sessionUsecase,
    required OutboxDaoInterface outboxDao,
    NostrEventCreator eventCreator = const NostrEventCreator(),
    Now now = const Now(),
  }) : _eventStore = eventStore,
       _noteCryptoUseCase = noteCryptoUseCase,
       _sessionUsecase = sessionUsecase,
       _outboxDao = outboxDao,
       _eventCreator = eventCreator,
       _now = now;

  @override
  Future<void> importNotes({
    required String password,
    String filePath = '',
    Uint8List? fileBytes,
    ImportPolicy policy = const ImportPolicy.mergeContent(),
  }) async {
    final payload = await _readFile(filePath, fileBytes);

    final session = _sessionUsecase.currentSession;
    final pubkey = session.pubkey;
    final privateKey = session.keys?.privateKey;
    if (privateKey == null || privateKey.isEmpty) {
      throw const ImportError(payload: ImportErrorType.notAuthenticated);
    }

    // 1) Decrypt every incoming note to plaintext (content/summary/labels).
    //    A failure here (key derivation or AES) means a wrong password or a
    //    corrupted backup.
    final plainNotes = <Note>[];
    try {
      final algData = await _prepareAlgDataIfNeeded(payload, password);
      for (final eventJson in payload.events) {
        final event = NostrEvent.fromJson(eventJson);
        final note = NoteMapper.fromNostrEvent(event);
        if (note == null) {
          continue;
        }

        final content = await _decryptFieldIfNeeded(note.content, algData);
        final summary = await _decryptFieldIfNeeded(note.summary, algData);
        final labels = await _decryptLabelsIfNeeded(note.labels, algData);

        plainNotes.add(
          note.copyWith(content: content, summary: summary, labels: labels),
        );
      }
    } on ImportError {
      rethrow;
    } catch (e) {
      throw ImportError(payload: ImportErrorType.wrongPassword, parentError: e);
    }

    try {
      // 2) Load already stored notes that share a d-tag with the import, so the
      //    policy can resolve each collision. Results keep their d-tag, so the
      //    store replaces the stored version natively (addressable events).
      final existingByDTag = await _loadExistingByDTag(plainNotes, pubkey);

      // 3) Resolve collisions, refresh summary when content changed, and build
      //    properly signed events under the current account's key.
      final eventsToStore = <NostrEvent>[];
      for (final incoming in plainNotes) {
        final existing = existingByDTag[incoming.dTag];
        final resolved = policy.apply(incoming, existing);
        final note = _withFreshSummary(resolved, incoming, existing);
        eventsToStore.add(
          await _buildSignedEvent(
            note: note,
            pubkey: pubkey,
            privateKey: privateKey,
          ),
        );
      }

      await _eventStore.upsert(eventsToStore);

      for (final event in eventsToStore) {
        await _outboxDao.insert(eventId: event.id);
      }
    } on ImportError {
      rethrow;
    } catch (e) {
      throw ImportError(payload: ImportErrorType.unknown, parentError: e);
    }
  }

  Future<BackupPayload> _readFile(String filePath, Uint8List? fileBytes) async {
    late final Uint8List bytes;
    if (fileBytes != null) {
      bytes = fileBytes;
    } else {
      final file = File(filePath);
      if (!await file.exists()) {
        throw const ImportError(payload: ImportErrorType.invalidFile);
      }
      bytes = await file.readAsBytes();
    }

    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      final jsonFile = archive.findFile(ExportUsecaseImpl.archivedFileName);
      if (jsonFile == null) {
        throw const ImportError(payload: ImportErrorType.invalidFile);
      }

      final payload = BackupPayload.fromJson(
        jsonDecode(utf8.decode(jsonFile.content as List<int>))
            as Map<String, dynamic>,
      );
      if (payload.version != 1) {
        throw const ImportError(payload: ImportErrorType.invalidFile);
      }

      return payload;
    } on ImportError {
      rethrow;
    } catch (e) {
      throw ImportError(payload: ImportErrorType.invalidFile, parentError: e);
    }
  }

  /// Loads and decrypts the stored notes whose d-tag matches any incoming one,
  /// keyed by d-tag. Only notes authored by [pubkey] are considered.
  Future<Map<String, Note>> _loadExistingByDTag(
    List<Note> incoming,
    String pubkey,
  ) async {
    final dTags = incoming
        .map((n) => n.dTag)
        .where((d) => d.isNotEmpty)
        .toList();
    if (dTags.isEmpty) {
      return const {};
    }

    final events = await _eventStore.queryEvents(
      RawEventQuery(
        kinds: [EventKind.note.value],
        authors: [pubkey],
        tagFilters: [TagFilter(Tag.d.value, dTags)],
      ),
    );

    final result = <String, Note>{};
    for (final event in events) {
      final note = NoteMapper.fromNostrEvent(event);
      if (note == null) continue;
      result[note.dTag] = await _noteCryptoUseCase.decryptNote(note);
    }
    return result;
  }

  /// The summary is derived from content, so it must be regenerated whenever a
  /// policy rewrote the content (MergeContent). keepIncoming/keepExisting leave
  /// content untouched and thus keep their already-correct summary.
  Note _withFreshSummary(Note resolved, Note incoming, Note? existing) {
    final contentChanged =
        resolved.content != incoming.content &&
        resolved.content != existing?.content;
    if (!contentChanged) {
      return resolved;
    }
    return resolved.copyWith(summary: CrerateSummaryHelper.create(resolved));
  }

  FutureOr<_AlgData?> _prepareAlgDataIfNeeded(
    BackupPayload payload,
    String password,
  ) async {
    if (!payload.encrypted) {
      return null;
    }

    final salt = HexToBytes.hexToBytes(payload.salt!);
    final iterations = payload.iterations ?? _kPbkdf2Iterations;
    final secretKey = await ExportHelper.deriveKey(password, salt, iterations);
    final algorithm = AesCbc.with256bits(macAlgorithm: Hmac.sha256());
    return _AlgData(secretKey, algorithm);
  }

  /// Re-encrypts [note] under the current account and produces a properly
  /// signed event (correct id + sig), reusing the note's d-tag.
  ///
  /// Date handling follows the Nostr/app conventions:
  /// - `created_at` is the publication timestamp and is refreshed to `now` on
  ///   every (re)publish — it feeds the event id/sig, and the store resolves
  ///   replaceable-event conflicts by it, so the result always supersedes the
  ///   stored version sharing the d-tag.
  /// - `init_at` (the `updated_at` tag) is carried over unchanged; an import is
  ///   not a user content edit.
  Future<NostrEvent> _buildSignedEvent({
    required Note note,
    required String pubkey,
    required String privateKey,
  }) async {
    final createdAt = _now.now();

    // Refresh created_at; keep the original init_at (note.updatedAt).
    final preparedNote = note.copyWith(createdAt: createdAt);

    final reEncrypted = await _noteCryptoUseCase.encryptNote(preparedNote);
    final tags = NoteMapper.toNostrEvent(reEncrypted, pubkey: pubkey).tags;

    return _eventCreator.createEvent(
      kind: EventKind.note.value,
      content: reEncrypted.content,
      createdAt: createdAt,
      tags: tags,
      pubkey: pubkey,
      privateKey: privateKey,
    );
  }

  FutureOr<String> _decryptFieldIfNeeded(String encoded, _AlgData? algData) {
    return algData == null ? encoded : _decryptField(encoded, algData);
  }

  Future<String> _decryptField(String encoded, _AlgData algData) async {
    if (encoded.isEmpty) return '';
    final parts = encoded.split('?iv=');
    final cipherText = base64Decode(parts[0]);
    final ivAndMac = parts[1].split('&mac=');
    final iv = base64Decode(ivAndMac[0]);
    final mac = Mac(base64Decode(ivAndMac[1]));
    final plainBytes = await algData.algorithm.decrypt(
      SecretBox(cipherText, nonce: iv, mac: mac),
      secretKey: algData.secretKey,
    );
    return utf8.decode(plainBytes);
  }

  FutureOr<List<BaseLabel>> _decryptLabelsIfNeeded(
    List<BaseLabel> labels,
    _AlgData? algData,
  ) {
    return algData == null ? labels : _decryptLabels(labels, algData);
  }

  Future<List<BaseLabel>> _decryptLabels(
    List<BaseLabel> labels,
    _AlgData algData,
  ) async {
    if (labels.isEmpty) return const [];
    final decrypted = await _decryptField(labels.first.textValue, algData);
    if (decrypted.isEmpty) return const [];
    return BaseLabel.fromJoinedText(decrypted);
  }
}

final class _AlgData {
  final SecretKey secretKey;
  final AesCbc algorithm;

  const _AlgData(this.secretKey, this.algorithm);
}
