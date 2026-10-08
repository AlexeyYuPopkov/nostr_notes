import 'package:common/domain/repo/key_tool_repository.dart';
import 'package:nostr/key_tool/key_tool.dart';
import 'package:nostr_notes/common/data/backup/backup_crypto_helper.dart';
import 'package:nostr_notes/common/data/backup/backup_file_writer.dart';
import 'package:nostr_notes/common/data/backup/backup_zip_helper.dart';
import 'package:nostr_notes/common/data/keys_backup/keys_backup_payload.dart';
import 'package:nostr_notes/common/data/keys_backup/keys_backup_templates.dart';
import 'package:nostr_notes/common/domain/usecase/keys_backup/export_keys_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/keys_backup/key_backup_entry.dart';
import 'package:nostr_notes/common/domain/usecase/keys_backup/keys_backup_error.dart';
import 'package:nostr_notes/services/hex_to_bytes.dart';

final class ExportKeysUsecaseImpl implements ExportKeysUsecase {
  static const archivedFileName = 'keys_export.json';
  static const decryptScriptName = 'decrypt_keys.py';
  static const _defaultFilePrefix = 'nostr_keys_backup_';

  final KeyToolRepository _keyToolRepository;

  const ExportKeysUsecaseImpl({required KeyToolRepository keyToolRepository})
    : _keyToolRepository = keyToolRepository;

  @override
  Future<KeysBackupFile> exportKeys({
    required List<KeyBackupEntry> keys,
    required String password,
    String? fileName,
  }) async {
    if (password.length < ExportKeysUsecase.minPasswordLength) {
      throw const KeysBackupError(
        payload: KeysBackupErrorType.passwordTooShort,
      );
    }
    if (keys.isEmpty) {
      throw const KeysBackupError(payload: KeysBackupErrorType.noKeys);
    }

    final npubs = keys.map(_npubOf).toList();

    final KeysBackupPayload payload;
    try {
      payload = await _createPayload(keys, npubs, password);
    } catch (e) {
      throw KeysBackupError(
        payload: KeysBackupErrorType.unknown,
        parentError: e,
      );
    }

    final resolvedFileName = BackupZipHelper.zipFileName(
      fileName,
      defaultPrefix: _defaultFilePrefix,
    );
    try {
      final bytes = BackupZipHelper.buildZipBytes(
        json: payload.toJson(),
        archivedFileName: archivedFileName,
        decryptScript: kKeysDecryptBackupPy,
        decryptScriptName: decryptScriptName,
        readme: kKeysBackupReadmeMd,
      );
      final filePath = await BackupFileWriter.writeToTemp(
        bytes,
        resolvedFileName,
      );
      return (filePath: filePath, bytes: bytes, fileName: resolvedFileName);
    } catch (e) {
      throw KeysBackupError(
        payload: KeysBackupErrorType.fileWriteFailed,
        parentError: e,
      );
    }
  }

  String _npubOf(KeyBackupEntry entry) {
    try {
      final keys = _keyToolRepository.getUserKeysWithNsec(nsec: entry.nsec);
      return KeyTool.npubKey(keys.publicKey);
    } catch (e) {
      throw KeysBackupError(
        payload: KeysBackupErrorType.invalidKey,
        parentError: e,
      );
    }
  }

  Future<KeysBackupPayload> _createPayload(
    List<KeyBackupEntry> keys,
    List<String> npubs,
    String password,
  ) async {
    final salt = BackupCryptoHelper.generateRandomBytes(16);
    final iterations = BackupCryptoHelper.iterations;
    final secretKey = await BackupCryptoHelper.deriveKey(
      password,
      salt,
      iterations,
    );
    final algorithm = BackupCryptoHelper.algorithm();

    final records = <KeysBackupRecord>[];
    for (final (index, entry) in keys.indexed) {
      records.add(
        KeysBackupRecord(
          npub: npubs[index],
          label: entry.label,
          nsec: await BackupCryptoHelper.encryptField(
            entry.nsec.trim(),
            secretKey,
            algorithm,
          ),
        ),
      );
    }

    return KeysBackupPayload(
      version: KeysBackupPayload.supportedVersion,
      type: KeysBackupPayload.payloadType,
      exportedAt: DateTime.now().toUtc().toIso8601String(),
      salt: HexToBytes.bytesToHex(salt),
      iterations: iterations,
      keys: records,
    );
  }
}
