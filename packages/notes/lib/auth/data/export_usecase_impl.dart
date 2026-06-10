import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

import 'package:archive/archive.dart';
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

const _kPbkdf2Iterations = 600000;

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
    required String password,
    required String fileUri,
  }) async {
    try {
      final events = await _eventStore.queryEvents(
        RawEventQuery(kinds: [EventKind.note.value]),
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
        payload = await _createPayload(decryptedNotes, password: password);
      } catch (e) {
        throw ExportError(
          payload: ExportErrorType.encryptionFailed,
          parentError: e,
        );
      }

      final fileName = _fileName();
      final Uint8List zipBytes;
      final String filePath;
      try {
        zipBytes = _buildZipBytes(payload);
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
      return BackupPayload(version: 1, encrypted: false, events: exportEvents);
    } else {
      final salt = _generateRandomBytes(16);
      final secretKey = await ExportHelper.deriveKey(
        password,
        salt,
        _kPbkdf2Iterations,
      );
      final algorithm = AesCbc.with256bits(macAlgorithm: Hmac.sha256());
      final exportEvents = <Map<String, dynamic>>[];

      for (final note in notes) {
        exportEvents.add(
          NoteMapper.toNostrEvent(
            note.copyWith(
              content: await _encryptField(note.content, secretKey, algorithm),
              summary: await _encryptField(note.summary, secretKey, algorithm),
              labels: await _encryptLabels(note.labels, secretKey, algorithm),
            ),
          ).toJson(),
        );
      }

      return BackupPayload(
        version: 1,
        encrypted: true,
        salt: HexToBytes.bytesToHex(salt),
        iterations: _kPbkdf2Iterations,
        events: exportEvents,
      );
    }
  }

  Uint8List _buildZipBytes(BackupPayload payload) {
    final jsonBytes = utf8.encode(
      const JsonEncoder.withIndent('  ').convert(payload.toJson()),
    );
    final archive = Archive()
      ..addFile(ArchiveFile(archivedFileName, jsonBytes.length, jsonBytes));
    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  Future<String> _writeToTempFile(Uint8List bytes, String fileName) async {
    final file = File('${(await getTemporaryDirectory()).path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  String _fileName() {
    const filePrefix = 'notes_backup_';
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return '$filePrefix$timestamp.zip';
  }

  Future<String> _encryptField(
    String text,
    SecretKey key,
    AesCbc algorithm,
  ) async {
    if (text.isEmpty) return '';
    final iv = _generateRandomBytes(16);
    final secretBox = await algorithm.encrypt(
      utf8.encode(text),
      secretKey: key,
      nonce: iv,
    );
    return '${base64Encode(secretBox.cipherText)}?iv=${base64Encode(iv)}&mac=${base64Encode(secretBox.mac.bytes)}';
  }

  Future<List<BaseLabel>> _encryptLabels(
    List<BaseLabel> labels,
    SecretKey key,
    AesCbc algorithm,
  ) async {
    if (labels.isEmpty) return const [];
    final joined = BaseLabel.joinLabels(labels.whereType<Label>());
    if (joined.isEmpty) return const [];
    final encrypted = await _encryptField(joined, key, algorithm);
    return [EncryptedLabel(textValue: encrypted)];
  }

  Uint8List _generateRandomBytes(int length) {
    final random = math.Random.secure();
    return Uint8List.fromList(
      List.generate(length, (_) => random.nextInt(256)),
    );
  }
}

abstract interface class ExportHelper {
  static Future<SecretKey> deriveKey(
    String password,
    Uint8List salt,
    int iterations,
  ) {
    return Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    ).deriveKeyFromPassword(password: password, nonce: salt);
  }
}
