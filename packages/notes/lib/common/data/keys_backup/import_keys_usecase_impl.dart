import 'dart:io';
import 'dart:typed_data';

import 'package:common/domain/repo/key_tool_repository.dart';
import 'package:nostr/key_tool/key_tool.dart';
import 'package:nostr_notes/common/data/backup/backup_crypto_helper.dart';
import 'package:nostr_notes/common/data/backup/backup_zip_helper.dart';
import 'package:nostr_notes/common/data/keys_backup/export_keys_usecase_impl.dart';
import 'package:nostr_notes/common/data/keys_backup/keys_backup_payload.dart';
import 'package:nostr_notes/common/domain/usecase/keys_backup/import_keys_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/keys_backup/key_backup_entry.dart';
import 'package:nostr_notes/common/domain/usecase/keys_backup/keys_backup_error.dart';
import 'package:nostr_notes/services/hex_to_bytes.dart';

final class ImportKeysUsecaseImpl implements ImportKeysUsecase {
  final KeyToolRepository _keyToolRepository;

  const ImportKeysUsecaseImpl({required KeyToolRepository keyToolRepository})
    : _keyToolRepository = keyToolRepository;

  @override
  Future<List<KeyBackupEntry>> importKeys({
    required String password,
    String filePath = '',
    Uint8List? fileBytes,
  }) async {
    final payload = await _readPayload(filePath, fileBytes);
    final records = await _decrypt(payload, password);
    return records.map(_verified).toList();
  }

  Future<KeysBackupPayload> _readPayload(
    String filePath,
    Uint8List? fileBytes,
  ) async {
    final Map<String, Object?>? json;
    try {
      final bytes = fileBytes ?? await File(filePath).readAsBytes();
      json = BackupZipHelper.readJson(
        bytes,
        ExportKeysUsecaseImpl.archivedFileName,
      );
    } catch (e) {
      throw KeysBackupError(
        payload: KeysBackupErrorType.invalidFile,
        parentError: e,
      );
    }

    if (json == null || json['type'] != KeysBackupPayload.payloadType) {
      throw const KeysBackupError(payload: KeysBackupErrorType.invalidFile);
    }
    final version = json['version'];
    if (version is! int || version > KeysBackupPayload.supportedVersion) {
      throw const KeysBackupError(
        payload: KeysBackupErrorType.unsupportedVersion,
      );
    }

    final KeysBackupPayload payload;
    try {
      payload = KeysBackupPayload.fromJson(json);
    } catch (e) {
      throw KeysBackupError(
        payload: KeysBackupErrorType.invalidFile,
        parentError: e,
      );
    }
    if (payload.keys.isEmpty) {
      throw const KeysBackupError(payload: KeysBackupErrorType.invalidFile);
    }
    return payload;
  }

  /// Any failure here means a wrong password or a corrupted backup: the MAC
  /// check cannot tell the two apart.
  Future<List<({KeysBackupRecord record, String nsec})>> _decrypt(
    KeysBackupPayload payload,
    String password,
  ) async {
    try {
      final secretKey = await BackupCryptoHelper.deriveKey(
        password,
        HexToBytes.hexToBytes(payload.salt),
        payload.iterations,
      );
      final algorithm = BackupCryptoHelper.algorithm();

      return [
        for (final record in payload.keys)
          (
            record: record,
            nsec: await BackupCryptoHelper.decryptField(
              record.nsec,
              secretKey,
              algorithm,
            ),
          ),
      ];
    } catch (e) {
      throw KeysBackupError(
        payload: KeysBackupErrorType.wrongPassword,
        parentError: e,
      );
    }
  }

  /// The stored npub is a checksum the user can read; a key that decrypts
  /// but derives another npub must not silently log into another account.
  KeyBackupEntry _verified(({KeysBackupRecord record, String nsec}) item) {
    final String npub;
    try {
      final keys = _keyToolRepository.getUserKeysWithNsec(nsec: item.nsec);
      npub = KeyTool.npubKey(keys.publicKey);
    } catch (e) {
      throw KeysBackupError(
        payload: KeysBackupErrorType.invalidKey,
        parentError: e,
      );
    }
    if (npub != item.record.npub) {
      throw const KeysBackupError(payload: KeysBackupErrorType.invalidKey);
    }
    return KeyBackupEntry(nsec: item.nsec, label: item.record.label);
  }
}
