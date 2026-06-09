import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:bip340/bip340.dart' as bip340;
import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:cryptography/cryptography.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr_notes/auth/data/export_usecase_impl.dart';
import 'package:nostr_notes/auth/data/import_usecase_impl.dart';
import 'package:nostr_notes/auth/data/mappers/note_mapper.dart';
import 'package:nostr_notes/auth/data/models/backup_payload.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/usecase/import_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';
import 'package:nostr_notes/services/hex_to_bytes.dart';

import '../../../integration_test/di/in_memory_db_module.dart';
import '../../tools/some_moked_data.dart';
import 'fixtures/notes_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async {
            if (call.method == 'getTemporaryDirectory') {
              return Directory.systemTemp.path;
            }
            return null;
          },
        );
  });

  const password = 'test_p@ssword_123';

  group('ExportUsecaseImpl + ImportUsecaseImpl', () {
    late RawEventStore eventStore;
    late NoteCryptoUseCase noteCryptoUseCase;
    late SessionUsecase sessionUsecase;
    late ExportUsecaseImpl exportSut;
    late ImportUsecaseImpl importSut;

    setUp(() async {
      final di = DiStorage.shared;
      const InMemoryDbModule().bind(di);
      eventStore = di.resolve<RawEventStore>();

      final cryptoService = CryptoService.create(
        Uint8List.fromList(SomeMokedData.randomBytes),
      );
      await cryptoService.init();

      sessionUsecase = SessionUsecase()
        ..setSession(
          const Session.unlocked(
            keys: NotesFixtures.keys,
            pin: NotesFixtures.pin,
          ),
        );

      noteCryptoUseCase = NoteCryptoUseCase(
        cryptoService: cryptoService,
        sessionUsecase: sessionUsecase,
        extraDerivation: ExtraDerivation(
          cryptoService: cryptoService,
          sessionUsecase: sessionUsecase,
        ),
      );

      exportSut = ExportUsecaseImpl(
        eventStore: eventStore,
        noteCryptoUseCase: noteCryptoUseCase,
      );

      importSut = ImportUsecaseImpl(
        eventStore: eventStore,
        noteCryptoUseCase: noteCryptoUseCase,
        sessionUsecase: sessionUsecase,
      );
    });

    tearDown(() async {
      sessionUsecase.dispose();
      await DiStorage.shared.resolve<AppDatabase>().close();
      DiStorage.shared.removeAll();
    });

    // Seeds the backup with the original note1, exports it, then replaces the
    // stored note with a diverged local edit under the SAME d-tag. Returns the
    // backup path; the store ends up holding only the local version, so the
    // import below hits a d-tag collision.
    Future<String> seedBackupThenDivergeLocally({
      required String localContent,
    }) async {
      final backupNote = await noteCryptoUseCase.decryptNote(
        NoteMapper.fromJsonStr(NotesFixtures.eventJson1)!,
      );

      await _seedEncryptedNote(
        eventStore: eventStore,
        noteCryptoUseCase: noteCryptoUseCase,
        note: backupNote,
      );

      final exportPath = await exportSut.exportNotes(
        password: password,
        fileUri: '',
      );

      await _clearNotes(eventStore);
      await _seedEncryptedNote(
        eventStore: eventStore,
        noteCryptoUseCase: noteCryptoUseCase,
        note: backupNote.copyWith(
          content: localContent,
          summary: 'local summary',
        ),
      );

      return exportPath;
    }

    test('returns empty string when no notes in the store', () async {
      final result = await exportSut.exportNotes(
        password: password,
        fileUri: '',
      );
      expect(result, isEmpty);
    });

    test('exports plaintext content when password is empty', () async {
      final note = await noteCryptoUseCase.decryptNote(
        NoteMapper.fromJsonStr(NotesFixtures.eventJson1)!,
      );

      await _seedEncryptedNote(
        eventStore: eventStore,
        noteCryptoUseCase: noteCryptoUseCase,
        note: note,
      );

      final filePath = await exportSut.exportNotes(password: '', fileUri: '');
      addTearDown(() => File(filePath).deleteSync());

      final payload = _readExportJson(filePath);

      expect(payload.encrypted, isFalse);
      expect(payload.salt, isNull);
      expect(payload.iterations, isNull);

      final eventMap = payload.events.first;
      final nostrEvent = NostrEvent.fromJson(eventMap);

      expect(nostrEvent.content, equals(NotesFixtures.event1Content));
      expect(
        _findTag(nostrEvent.tags as List<dynamic>, 'summary'),
        equals(NotesFixtures.event1Summary),
      );
      expect(
        nostrEvent.getTagsList(Note.labelsTag).first,
        equals(NotesFixtures.event1Labels),
      );
    });

    test(
      'encrypted export JSON has encrypted flag, salt, and iterations',
      () async {
        final note = await noteCryptoUseCase.decryptNote(
          NoteMapper.fromJsonStr(NotesFixtures.eventJson1)!,
        );

        await _seedEncryptedNote(
          eventStore: eventStore,
          noteCryptoUseCase: noteCryptoUseCase,
          note: note,
        );

        final filePath = await exportSut.exportNotes(
          password: password,
          fileUri: '',
        );
        addTearDown(() => File(filePath).deleteSync());

        final payload = _readExportJson(filePath);

        expect(payload.encrypted, isTrue);
        expect(payload.salt, isA<String>());
        expect(payload.salt, isNotEmpty);
        expect(payload.iterations, equals(600000));
      },
    );

    test('creates a valid ZIP file containing notes_export.json', () async {
      final note = await noteCryptoUseCase.decryptNote(
        NoteMapper.fromJsonStr(NotesFixtures.eventJson1)!,
      );

      await _seedEncryptedNote(
        eventStore: eventStore,
        noteCryptoUseCase: noteCryptoUseCase,
        note: note,
      );

      final filePath = await exportSut.exportNotes(
        password: password,
        fileUri: '',
      );
      addTearDown(() => File(filePath).deleteSync());

      expect(filePath, isNotEmpty);
      expect(File(filePath).existsSync(), isTrue);
      expect(
        ZipDecoder()
            .decodeBytes(File(filePath).readAsBytesSync())
            .findFile(ExportUsecaseImpl.archivedFileName),
        isNotNull,
      );
    });

    test('export JSON has correct structure and one event per note', () async {
      // eventJson2 is used here to verify its specific event ID is preserved
      final note = await noteCryptoUseCase.decryptNote(
        NoteMapper.fromJsonStr(NotesFixtures.eventJson2)!,
      );

      await _seedEncryptedNote(
        eventStore: eventStore,
        noteCryptoUseCase: noteCryptoUseCase,
        note: note,
      );

      final filePath = await exportSut.exportNotes(
        password: password,
        fileUri: '',
      );
      addTearDown(() => File(filePath).deleteSync());

      final payload = _readExportJson(filePath);

      expect(payload.version, equals(1));
      expect(payload.encrypted, isTrue);
      expect(payload.iterations, equals(600000));
      expect(payload.salt, isNotEmpty);
      expect(payload.events, hasLength(1));

      final event = payload.events.first;
      expect(
        event['id'],
        equals(
          'abd1e0dd92bdd51e7b08f56822b72177ea8e4b303f3817865f44beccdc193ea4',
        ),
      );
      expect(event['kind'], equals(EventKind.note.value));
      expect(
        _findTag(event['tags'] as List<dynamic>, 'd'),
        equals('ca980f90-22c9-11f1-b2b7-af1d94bcfeaf'),
      );
    });

    test(
      'encrypted fields (content, summary, labels) contain iv and mac markers',
      () async {
        final note = await noteCryptoUseCase.decryptNote(
          NoteMapper.fromJsonStr(NotesFixtures.eventJson1)!,
        );

        await _seedEncryptedNote(
          eventStore: eventStore,
          noteCryptoUseCase: noteCryptoUseCase,
          note: note,
        );

        final filePath = await exportSut.exportNotes(
          password: password,
          fileUri: '',
        );
        addTearDown(() => File(filePath).deleteSync());

        final payload = _readExportJson(filePath);
        final event = payload.events.first;

        final encryptedContent = event['content'] as String;
        expect(encryptedContent, isNot(equals(NotesFixtures.event1Content)));
        expect(encryptedContent, contains('?iv='));
        expect(encryptedContent, contains('&mac='));

        final encryptedSummary = _findTag(
          event['tags'] as List<dynamic>,
          'summary',
        );
        expect(encryptedSummary, isNot(equals(NotesFixtures.event1Summary)));
        expect(encryptedSummary, contains('?iv='));
        expect(encryptedSummary, contains('&mac='));

        final encryptedLabels = _findTag(
          event['tags'] as List<dynamic>,
          Note.labelsTag,
        );
        expect(encryptedLabels, isNot(equals(NotesFixtures.event1Labels)));
        expect(encryptedLabels, contains('?iv='));
        expect(encryptedLabels, contains('&mac='));
      },
    );

    test('encrypted content can be decrypted back to original', () async {
      final note1 = await noteCryptoUseCase.decryptNote(
        NoteMapper.fromJsonStr(NotesFixtures.eventJson1)!,
      );
      final note2 = await noteCryptoUseCase.decryptNote(
        NoteMapper.fromJsonStr(NotesFixtures.eventJson2)!,
      );

      await _seedEncryptedNote(
        eventStore: eventStore,
        noteCryptoUseCase: noteCryptoUseCase,
        note: note1,
      );
      await _seedEncryptedNote(
        eventStore: eventStore,
        noteCryptoUseCase: noteCryptoUseCase,
        note: note2,
      );

      final filePath = await exportSut.exportNotes(
        password: password,
        fileUri: '',
      );
      addTearDown(() => File(filePath).deleteSync());

      final payload = _readExportJson(filePath);
      final salt = HexToBytes.hexToBytes(payload.salt!);
      expect(payload.events, hasLength(2));

      Map<String, dynamic> findById(String id) =>
          payload.events.firstWhere((e) => e['id'] == id);

      final ev1 = findById(
        'a826d76e943cab49f4d10cbc7c609e8b2f34c1f215ac4db7d4a55af96aa57dbd',
      );
      final ev2 = findById(
        'abd1e0dd92bdd51e7b08f56822b72177ea8e4b303f3817865f44beccdc193ea4',
      );

      expect(
        await _decryptExportField(
          ev1['content'] as String,
          password: password,
          salt: salt,
        ),
        equals(NotesFixtures.event1Content),
      );
      expect(
        await _decryptExportField(
          _findTag(ev1['tags'] as List<dynamic>, 'summary'),
          password: password,
          salt: salt,
        ),
        equals(NotesFixtures.event1Summary),
      );
      expect(
        await _decryptExportField(
          _findTag(ev1['tags'] as List<dynamic>, Note.labelsTag),
          password: password,
          salt: salt,
        ),
        equals(NotesFixtures.event1Labels),
      );
      expect(
        await _decryptExportField(
          ev2['content'] as String,
          password: password,
          salt: salt,
        ),
        equals(NotesFixtures.event2Content),
      );
      expect(
        await _decryptExportField(
          _findTag(ev2['tags'] as List<dynamic>, 'summary'),
          password: password,
          salt: salt,
        ),
        equals(NotesFixtures.event2Summary),
      );
    });

    group('importNotes', () {
      test('throws when file does not exist', () async {
        await expectLater(
          importSut.importNotes(
            password: password,
            filePath: '/tmp/nonexistent.zip',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test(
        'round-trip (encrypted): content, summary and labels survive export → import',
        () async {
          final original = await noteCryptoUseCase.decryptNote(
            NoteMapper.fromJsonStr(NotesFixtures.eventJson1)!,
          );

          await _seedEncryptedNote(
            eventStore: eventStore,
            noteCryptoUseCase: noteCryptoUseCase,
            note: original,
          );

          final exportPath = await exportSut.exportNotes(
            password: password,
            fileUri: '',
          );
          addTearDown(() => File(exportPath).deleteSync());

          await _clearNotes(eventStore);

          await importSut.importNotes(password: password, filePath: exportPath);

          final storedEvents = await eventStore.queryEvents(
            RawEventQuery(kinds: [EventKind.note.value]),
          );
          expect(storedEvents, isNotEmpty);

          final decrypted = await noteCryptoUseCase.decryptNote(
            NoteMapper.fromNostrEvent(storedEvents.first)!,
          );
          expect(decrypted.content, equals(NotesFixtures.event1Content));
          expect(decrypted.summary, equals(NotesFixtures.event1Summary));
          expect(decrypted.labels, equals(original.labels));
          expect(
            (decrypted.labels.first as Label).type,
            equals(CategoryType.security),
          );
        },
      );

      test(
        'round-trip (plaintext): content, summary and labels survive export → import',
        () async {
          final original = await noteCryptoUseCase.decryptNote(
            NoteMapper.fromJsonStr(NotesFixtures.eventJson1)!,
          );

          await _seedEncryptedNote(
            eventStore: eventStore,
            noteCryptoUseCase: noteCryptoUseCase,
            note: original,
          );

          final exportPath = await exportSut.exportNotes(
            password: '',
            fileUri: '',
          );
          addTearDown(() => File(exportPath).deleteSync());

          await _clearNotes(eventStore);

          await importSut.importNotes(password: '', filePath: exportPath);

          final storedEvents = await eventStore.queryEvents(
            RawEventQuery(kinds: [EventKind.note.value]),
          );
          expect(storedEvents, isNotEmpty);

          final decrypted = await noteCryptoUseCase.decryptNote(
            NoteMapper.fromNostrEvent(storedEvents.first)!,
          );
          expect(decrypted.content, equals(NotesFixtures.event1Content));
          expect(decrypted.summary, equals(NotesFixtures.event1Summary));
          expect(decrypted.labels, equals(original.labels));
          expect(
            (decrypted.labels.first as Label).type,
            equals(CategoryType.security),
          );
        },
      );

      test('import with wrong password throws on decryption', () async {
        final note = await noteCryptoUseCase.decryptNote(
          NoteMapper.fromJsonStr(NotesFixtures.eventJson1)!,
        );

        await _seedEncryptedNote(
          eventStore: eventStore,
          noteCryptoUseCase: noteCryptoUseCase,
          note: note,
        );

        final exportPath = await exportSut.exportNotes(
          password: password,
          fileUri: '',
        );
        addTearDown(() => File(exportPath).deleteSync());

        await expectLater(
          importSut.importNotes(
            password: 'wrong_password',
            filePath: exportPath,
          ),
          throwsA(anything),
        );
      });

      test('no collision: original d-tags are preserved', () async {
        final note1 = await noteCryptoUseCase.decryptNote(
          NoteMapper.fromJsonStr(NotesFixtures.eventJson1)!,
        );
        final note2 = await noteCryptoUseCase.decryptNote(
          NoteMapper.fromJsonStr(NotesFixtures.eventJson2)!,
        );

        // Backup contains note1 + note2.
        await _seedEncryptedNote(
          eventStore: eventStore,
          noteCryptoUseCase: noteCryptoUseCase,
          note: note1,
        );
        await _seedEncryptedNote(
          eventStore: eventStore,
          noteCryptoUseCase: noteCryptoUseCase,
          note: note2,
        );

        final exportPath = await exportSut.exportNotes(
          password: password,
          fileUri: '',
        );
        addTearDown(() => File(exportPath).deleteSync());

        // Empty store before import → no collisions for any policy.
        await _clearNotes(eventStore);

        await importSut.importNotes(password: password, filePath: exportPath);

        final all = await eventStore.queryEvents(
          RawEventQuery(kinds: [EventKind.note.value]),
        );
        expect(all, hasLength(2));
        final dTags = all.map((e) => e.getDTag()).toSet();
        expect(dTags, equals({note1.dTag, note2.dTag}));
      });

      test(
        'keepIncoming: imported note overwrites the diverged local one',
        () async {
          final exportPath = await seedBackupThenDivergeLocally(
            localContent: 'Local edit',
          );
          addTearDown(() => File(exportPath).deleteSync());

          await importSut.importNotes(
            password: password,
            filePath: exportPath,
            policy: const ImportPolicy.keepIncoming(),
          );

          final all = await eventStore.queryEvents(
            RawEventQuery(kinds: [EventKind.note.value]),
          );
          // Same d-tag → replaced, not duplicated.
          expect(all, hasLength(1));

          final decrypted = await noteCryptoUseCase.decryptNote(
            NoteMapper.fromNostrEvent(all.first)!,
          );
          expect(decrypted.content, equals(NotesFixtures.event1Content));
        },
      );

      test('keepExisting: the stored local note wins', () async {
        const localContent = 'Local edit kept on conflict';
        final exportPath = await seedBackupThenDivergeLocally(
          localContent: localContent,
        );
        addTearDown(() => File(exportPath).deleteSync());

        await importSut.importNotes(
          password: password,
          filePath: exportPath,
          policy: const ImportPolicy.keepExisting(),
        );

        final all = await eventStore.queryEvents(
          RawEventQuery(kinds: [EventKind.note.value]),
        );
        expect(all, hasLength(1));

        final decrypted = await noteCryptoUseCase.decryptNote(
          NoteMapper.fromNostrEvent(all.first)!,
        );
        expect(decrypted.content, equals(localContent));
      });

      test(
        'mergeContent: concatenates both contents and regenerates summary',
        () async {
          const localContent = 'LOCAL note body';
          final exportPath = await seedBackupThenDivergeLocally(
            localContent: localContent,
          );
          addTearDown(() => File(exportPath).deleteSync());

          await importSut.importNotes(
            password: password,
            filePath: exportPath,
            policy: const ImportPolicy.mergeContent(),
          );

          final all = await eventStore.queryEvents(
            RawEventQuery(kinds: [EventKind.note.value]),
          );
          // Same d-tag → merged in place, not duplicated.
          expect(all, hasLength(1));

          final decrypted = await noteCryptoUseCase.decryptNote(
            NoteMapper.fromNostrEvent(all.first)!,
          );
          // Existing content first, then the imported one.
          expect(decrypted.content, startsWith(localContent));
          expect(decrypted.content, contains(MergeContent.separator));
          expect(decrypted.content, contains(NotesFixtures.event1Content));
          // Summary is regenerated from the merged content (no longer stale).
          expect(decrypted.summary, contains(localContent));
        },
      );
    });

    group('cross-account import', () {
      test(
        'export with account A → import to account B → content, summary and labels decryptable only by B',
        () async {
          final original = await noteCryptoUseCase.decryptNote(
            NoteMapper.fromJsonStr(NotesFixtures.eventJson1)!,
          );

          await _seedEncryptedNote(
            eventStore: eventStore,
            noteCryptoUseCase: noteCryptoUseCase,
            note: original,
          );

          final exportPath = await exportSut.exportNotes(
            password: password,
            fileUri: '',
          );
          addTearDown(() => File(exportPath).deleteSync());

          await _clearNotes(eventStore);

          // ── Account B ────────────────────────────────────────────────────
          const privateKeyB =
              'b7e151628aed2a6abf7158809cf4f3c762e7160f38b4da56a784d9045190cfef';
          final publicKeyB = bip340.getPublicKey(privateKeyB);

          final cryptoServiceB = CryptoService.create(
            Uint8List.fromList(SomeMokedData.randomBytes),
          );
          await cryptoServiceB.init();

          final sessionB = SessionUsecase()
            ..setSession(
              Session.unlocked(
                keys: UserKeys(privateKey: privateKeyB, publicKey: publicKeyB),
                pin: '5678',
              ),
            );
          addTearDown(sessionB.dispose);

          final noteCryptoB = NoteCryptoUseCase(
            cryptoService: cryptoServiceB,
            sessionUsecase: sessionB,
            extraDerivation: ExtraDerivation(
              cryptoService: cryptoServiceB,
              sessionUsecase: sessionB,
            ),
          );

          final importSutB = ImportUsecaseImpl(
            eventStore: eventStore,
            noteCryptoUseCase: noteCryptoB,
            sessionUsecase: sessionB,
          );

          await importSutB.importNotes(
            password: password,
            filePath: exportPath,
          );

          final storedEvents = await eventStore.queryEvents(
            RawEventQuery(kinds: [EventKind.note.value]),
          );
          expect(storedEvents, isNotEmpty);

          // Account B can decrypt content, summary and labels
          final decryptedByB = await noteCryptoB.decryptNote(
            NoteMapper.fromNostrEvent(storedEvents.first)!,
          );
          expect(decryptedByB.content, equals(NotesFixtures.event1Content));
          expect(decryptedByB.summary, equals(NotesFixtures.event1Summary));
          expect(decryptedByB.labels, equals(original.labels));
          expect(
            (decryptedByB.labels.first as Label).type,
            equals(CategoryType.security),
          );

          // Account A cannot decrypt (different NIP-44 conversation key)
          await expectLater(
            noteCryptoUseCase.decryptNote(
              NoteMapper.fromNostrEvent(storedEvents.first)!,
            ),
            throwsA(anything),
          );
        },
      );
    });
  });
}

// ── helpers ────────────────────────────────────────────────────────────────

Future<void> _seedEncryptedNote({
  required RawEventStore eventStore,
  required NoteCryptoUseCase noteCryptoUseCase,
  required Note note,
}) async {
  final encrypted = await noteCryptoUseCase.encryptNote(note);
  await eventStore.upsert([
    NoteMapper.toNostrEvent(encrypted, pubkey: NotesFixtures.keys.publicKey),
  ]);
}

Future<void> _clearNotes(RawEventStore eventStore) async {
  final events = await eventStore.queryEvents(
    RawEventQuery(kinds: [EventKind.note.value]),
  );
  if (events.isNotEmpty) {
    await eventStore.deleteEvents(events.map((e) => e.id).toSet());
  }
}

BackupPayload _readExportJson(String zipFilePath) {
  final archive = ZipDecoder().decodeBytes(File(zipFilePath).readAsBytesSync());
  final jsonBytes =
      archive.findFile(ExportUsecaseImpl.archivedFileName)!.content
          as List<int>;
  return BackupPayload.fromJson(
    jsonDecode(utf8.decode(jsonBytes)) as Map<String, dynamic>,
  );
}

String _findTag(List<dynamic> tags, String name) {
  final tag =
      tags.firstWhere((t) => (t as List<dynamic>).first == name)
          as List<dynamic>;
  return tag[1] as String;
}

Future<String> _decryptExportField(
  String encoded, {
  required String password,
  required Uint8List salt,
}) async {
  final parts = encoded.split('?iv=');
  final cipherText = base64Decode(parts[0]);
  final ivAndMac = parts[1].split('&mac=');
  final iv = base64Decode(ivAndMac[0]);
  final mac = Mac(base64Decode(ivAndMac[1]));

  final secretKey = await Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 600000,
    bits: 256,
  ).deriveKeyFromPassword(password: password, nonce: salt);

  final plainBytes = await AesCbc.with256bits(macAlgorithm: Hmac.sha256())
      .decrypt(
        SecretBox(cipherText, nonce: iv, mac: mac),
        secretKey: secretKey,
      );

  return utf8.decode(plainBytes);
}
