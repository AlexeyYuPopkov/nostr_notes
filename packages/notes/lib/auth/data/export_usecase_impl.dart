import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:nostr_notes/auth/data/backup/backup_crypto_helper.dart';
import 'package:nostr_notes/auth/data/backup/backup_zip_helper.dart';
import 'package:nostr_notes/auth/data/backup_templates.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:cryptography/cryptography.dart';
import 'package:nostr_notes/auth/data/mappers/note_mapper.dart';
import 'package:nostr_notes/auth/data/models/backup_payload.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/usecase/export_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/services/hex_to_bytes.dart';
import 'package:path_provider/path_provider.dart';

const _kPbkdf2Iterations = BackupCryptoHelper.defaultIterations;

final class ExportUsecaseImpl implements ExportUsecase {
  static const archivedFileName = 'notes_export.json';
  final RawEventStore _eventStore;
  final NoteCryptoUseCase _noteCryptoUseCase;

  const ExportUsecaseImpl({
    required RawEventStore eventStore,
    required NoteCryptoUseCase noteCryptoUseCase,
  }) : _eventStore = eventStore,
       _noteCryptoUseCase = noteCryptoUseCase;

  @override
  Future<(String, Uint8List, String)> exportNotes({
    required ExportParams params,
  }) async {
    try {
      final noteIds = switch (params) {
        ExportParamsIds(:final noteIds) => noteIds,
        ExportParamsAll() => null,
      };
      final events = await _eventStore.queryEvents(
        RawEventQuery(
          kinds: [EventKind.note.value],
          tagFilters: noteIds != null ? [TagFilter('d', noteIds)] : null,
        ),
      );

      // Nothing stored — surfaced as empty bytes so the caller can show the
      // "no notes" message; not an error per se.
      if (events.isEmpty) {
        return ('', Uint8List(0), '');
      }

      final notes = NoteMapper.fromNostrEvents(events);
      final decryptedNotes = <Note>[];
      for (final note in notes) {
        try {
          final item = await _noteCryptoUseCase.decryptNote(note);
          decryptedNotes.add(item);
        } catch (e) {
          log(e.toString(), name: 'ExportUsecase');
          continue;
        }
      }

      if (decryptedNotes.isEmpty) {
        return ('', Uint8List(0), '');
      }

      final BackupPayload payload;
      try {
        payload = await _createPayload(
          decryptedNotes,
          password: params.password,
        );
      } catch (e) {
        throw ExportError(
          payload: ExportErrorType.encryptionFailed,
          parentError: e,
        );
      }

      final fileName = _fileName(params.fileName);
      final Uint8List zipBytes;
      final String filePath;
      try {
        zipBytes = await _buildZipBytes(payload);
        filePath = kIsWeb ? '' : await _writeToTempFile(zipBytes, fileName);
      } catch (e) {
        throw ExportError(
          payload: ExportErrorType.fileWriteFailed,
          parentError: e,
        );
      }

      if (zipBytes.isEmpty) {
        throw const ExportError(payload: ExportErrorType.fileWriteFailed);
      }

      return (filePath, zipBytes, fileName);
    } on ExportError {
      rethrow;
    } catch (e) {
      throw ExportError(payload: ExportErrorType.unknown, parentError: e);
    }
  }

  Future<BackupPayload> _createPayload(
    List<Note> notes, {
    required String password,
  }) async {
    if (password.isEmpty) {
      final exportEvents = <Map<String, dynamic>>[];
      for (final note in notes) {
        exportEvents.add(NoteMapper.toNostrEvent(note).toJson());
      }
      return BackupPayload(
        version: 1,
        encrypted: false,
        exportedAt: DateTime.now().toUtc().toIso8601String(),
        events: exportEvents,
      );
    } else {
      final salt = BackupCryptoHelper.generateRandomBytes(16);
      final secretKey = await BackupCryptoHelper.deriveKey(
        password,
        salt,
        _kPbkdf2Iterations,
      );
      final algorithm = BackupCryptoHelper.algorithm();
      final exportEvents = <Map<String, dynamic>>[];

      for (final note in notes) {
        exportEvents.add(
          NoteMapper.toNostrEvent(
            note.copyWith(
              content: await BackupCryptoHelper.encryptField(
                note.content,
                secretKey,
                algorithm,
              ),
              summary: await BackupCryptoHelper.encryptField(
                note.summary,
                secretKey,
                algorithm,
              ),
              labels: await _encryptLabels(note.labels, secretKey, algorithm),
            ),
          ).toJson(),
        );
      }

      return BackupPayload(
        version: 1,
        encrypted: true,
        exportedAt: DateTime.now().toUtc().toIso8601String(),
        salt: HexToBytes.bytesToHex(salt),
        iterations: _kPbkdf2Iterations,
        events: exportEvents,
      );
    }
  }

  Future<Uint8List> _buildZipBytes(BackupPayload payload) async {
    return BackupZipHelper.buildZipBytes(
      payload: payload,
      archivedFileName: archivedFileName,
      decryptScript: kDecryptBackupPy,
      readme: kBackupReadmeMd,
    );
  }

  Future<String> _writeToTempFile(Uint8List bytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    await dir.create(recursive: true);
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  String _fileName(String? customName) {
    final sanitized = BackupZipHelper.sanitizeFileName(customName);
    if (sanitized != null) return '$sanitized.zip';

    const filePrefix = 'notes_backup_';
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return '$filePrefix$timestamp.zip';
  }

  Future<List<BaseLabel>> _encryptLabels(
    List<BaseLabel> labels,
    SecretKey key,
    AesCbc algorithm,
  ) async {
    if (labels.isEmpty) return const [];
    final joined = BaseLabel.joinLabels(labels.whereType<Label>());
    if (joined.isEmpty) return const [];
    final encrypted = await BackupCryptoHelper.encryptField(
      joined,
      key,
      algorithm,
    );
    return [EncryptedLabel(textValue: encrypted)];
  }
}
