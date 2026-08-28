import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:nostr_notes/auth/data/backup/backup_crypto_helper.dart';
import 'package:nostr_notes/auth/data/backup/backup_zip_helper.dart';
import 'package:nostr_notes/auth/data/login_items/export_accounts_usecase_impl.dart';
import 'package:nostr_notes/auth/data/models/backup_payload.dart';
import 'package:nostr_notes/auth/data/models/login_item_payload.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/get_login_item_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/import_accounts_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/save_login_item_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/vault_identity_usecase.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/services/hex_to_bytes.dart';

/// Mirrors `ImportUsecaseImpl` (notes) but delegates the actual write to
/// [SaveLoginItemUsecase] instead of hand-rolling event signing: unlike a
/// note import (which needs custom summary regeneration and doesn't have a
/// single "save an item" usecase to call), every login item write already
/// goes through the same encrypt-sign-store-outbox path regardless of
/// whether it originates from the form or a backup, so reusing it here is
/// both less code and automatically consistent with it.
final class ImportAccountsUsecaseImpl implements ImportAccountsUsecase {
  final VaultIdentityUsecase _vaultIdentityUsecase;
  final GetLoginItemUsecase _getLoginItemUsecase;
  final SaveLoginItemUsecase _saveLoginItemUsecase;

  const ImportAccountsUsecaseImpl({
    required VaultIdentityUsecase vaultIdentityUsecase,
    required GetLoginItemUsecase getLoginItemUsecase,
    required SaveLoginItemUsecase saveLoginItemUsecase,
  }) : _vaultIdentityUsecase = vaultIdentityUsecase,
       _getLoginItemUsecase = getLoginItemUsecase,
       _saveLoginItemUsecase = saveLoginItemUsecase;

  @override
  Future<void> importAccounts({
    required String password,
    String filePath = '',
    Uint8List? fileBytes,
    LoginItemImportPolicy policy = const LoginItemImportPolicy.keepNewest(),
  }) async {
    if (password.trim().isEmpty) {
      throw const ImportAccountsError(
        payload: ImportAccountsErrorType.passwordRequired,
      );
    }

    try {
      // Fails fast (before touching the file) if there's no unlocked
      // session — mirrors the notes importer's own upfront auth check.
      _vaultIdentityUsecase.execute();
    } catch (e) {
      throw ImportAccountsError(
        payload: ImportAccountsErrorType.notAuthenticated,
        parentError: e,
      );
    }

    final payload = await _readFileAndZip(filePath, fileBytes);

    // 1) Decrypt every incoming item to plaintext. A failure here means a
    //    wrong password or a corrupted backup.
    final incoming = <LoginItem>[];
    try {
      final algData = await _prepareAlgData(payload, password);
      for (final eventJson in payload.events) {
        final item = await _parseAndDecryptEvent(eventJson, algData);
        if (item != null) incoming.add(item);
      }
    } on ImportAccountsError {
      rethrow;
    } catch (e) {
      throw ImportAccountsError(
        payload: ImportAccountsErrorType.wrongPassword,
        parentError: e,
      );
    }

    // 2) Resolve each collision against the currently stored item (if any)
    //    and persist through the normal save path.
    try {
      for (final item in incoming) {
        final existing = await _getLoginItemUsecase.execute(dTag: item.dTag);
        final resolved = policy.apply(item, existing);
        await _saveLoginItemUsecase.execute(item: resolved);
      }
    } on ImportAccountsError {
      rethrow;
    } catch (e) {
      throw ImportAccountsError(
        payload: ImportAccountsErrorType.unknown,
        parentError: e,
      );
    }
  }

  Future<BackupPayload> _readFileAndZip(
    String filePath,
    Uint8List? fileBytes,
  ) async {
    try {
      final bytes = fileBytes ?? await _readFile(filePath);
      final payload = BackupZipHelper.readPayload(
        bytes,
        ExportAccountsUsecaseImpl.archivedFileName,
      );
      if (payload == null || payload.version != 1) {
        throw const ImportAccountsError(
          payload: ImportAccountsErrorType.invalidFile,
        );
      }
      return payload;
    } on ImportAccountsError {
      rethrow;
    } catch (e) {
      throw ImportAccountsError(
        payload: ImportAccountsErrorType.invalidFile,
        parentError: e,
      );
    }
  }

  Future<List<int>> _readFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const ImportAccountsError(
        payload: ImportAccountsErrorType.invalidFile,
      );
    }
    return file.readAsBytes();
  }

  /// Accounts backups are always encrypted (see [ImportAccountsUsecase]),
  /// so unlike notes' importer there is no "unencrypted" branch to support.
  Future<_AlgData> _prepareAlgData(
    BackupPayload payload,
    String password,
  ) async {
    if (!payload.encrypted || payload.salt == null) {
      throw const ImportAccountsError(
        payload: ImportAccountsErrorType.invalidFile,
      );
    }
    final salt = HexToBytes.hexToBytes(payload.salt!);
    final iterations =
        payload.iterations ?? BackupCryptoHelper.defaultIterations;
    final secretKey = await BackupCryptoHelper.deriveKey(
      password,
      salt,
      iterations,
    );
    return _AlgData(secretKey, BackupCryptoHelper.algorithm());
  }

  /// Reads the `d` tag and decrypts+parses `content` back into a
  /// [LoginItem]. Returns null for malformed/non-account entries, so a
  /// stray non-31023 event in the file is skipped rather than failing the
  /// whole import.
  Future<LoginItem?> _parseAndDecryptEvent(
    Map<String, dynamic> eventJson,
    _AlgData algData,
  ) async {
    final kind = eventJson['kind'] as int?;
    if (kind != NostrKind.loginItem) return null;

    final tags = (eventJson['tags'] as List?) ?? const [];
    String? dTag;
    for (final tag in tags) {
      if (tag is List && tag.length >= 2 && tag.first == 'd') {
        dTag = tag[1] as String;
        break;
      }
    }
    if (dTag == null || dTag.isEmpty) return null;

    final content = eventJson['content'] as String? ?? '';
    if (content.isEmpty) return null;

    final plainJson = await BackupCryptoHelper.decryptField(
      content,
      algData.secretKey,
      algData.algorithm,
    );
    final payload = LoginItemPayload.fromJson(
      jsonDecode(plainJson) as Map<String, dynamic>,
    );

    final createdAtSeconds = eventJson['created_at'] as int? ?? 0;

    return LoginItem(
      eventId: eventJson['id'] as String? ?? '',
      dTag: dTag,
      title: payload.title,
      username: payload.username,
      password: payload.password,
      websiteUrl: payload.url,
      notes: payload.notes,
      image: payload.image ?? '',
      totpSecret: payload.totp,
      revision: payload.rev,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        createdAtSeconds * 1000,
        isUtc: true,
      ),
      updatedAt: payload.updatedAt == null
          ? DateTime.fromMillisecondsSinceEpoch(
              createdAtSeconds * 1000,
              isUtc: true,
            )
          : DateTime.fromMillisecondsSinceEpoch(
              payload.updatedAt! * 1000,
              isUtc: true,
            ),
    );
  }
}

final class _AlgData {
  final SecretKey secretKey;
  final AesCbc algorithm;
  const _AlgData(this.secretKey, this.algorithm);
}
