import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr_notes/auth/data/backup/backup_crypto_helper.dart';
import 'package:nostr_notes/auth/data/backup/backup_zip_helper.dart';
import 'package:nostr_notes/auth/data/backup_templates_accounts.dart';
import 'package:nostr_notes/auth/data/mappers/login_item_mapper.dart';
import 'package:nostr_notes/auth/data/models/backup_payload.dart';
import 'package:nostr_notes/auth/data/models/login_item_payload.dart';
import 'package:nostr_notes/auth/domain/model/encrypted_login_item.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/export_accounts_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/login_item_crypto_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/vault_identity_usecase.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/services/hex_to_bytes.dart';
import 'package:path_provider/path_provider.dart';

/// Mirrors `ExportUsecaseImpl` (notes) but over login items — see that class
/// for the shared zip/crypto plumbing (`BackupCryptoHelper`/`BackupZipHelper`).
/// The one structural difference: a login item's plaintext is a single
/// [LoginItemPayload] JSON blob (matching how it's already NIP-44-encrypted
/// on the wire), not separate content/summary/labels fields — so the whole
/// blob is encrypted as one field, and [password] is mandatory (see
/// [ExportAccountsUsecase] for why).
final class ExportAccountsUsecaseImpl implements ExportAccountsUsecase {
  static const archivedFileName = 'accounts_export.json';

  final RawEventStore _eventStore;
  final VaultIdentityUsecase _vaultIdentityUsecase;
  final LoginItemCryptoUsecase _loginItemCryptoUsecase;

  const ExportAccountsUsecaseImpl({
    required RawEventStore eventStore,
    required VaultIdentityUsecase vaultIdentityUsecase,
    required LoginItemCryptoUsecase loginItemCryptoUsecase,
  }) : _eventStore = eventStore,
       _vaultIdentityUsecase = vaultIdentityUsecase,
       _loginItemCryptoUsecase = loginItemCryptoUsecase;

  @override
  Future<(String, Uint8List, String)> exportAccounts({
    required String password,
    String? fileName,
    List<String>? dTags,
  }) async {
    if (password.trim().isEmpty) {
      throw const ExportAccountsError(
        payload: ExportAccountsErrorType.passwordRequired,
      );
    }

    try {
      final vaultPubkey = _vaultIdentityUsecase.execute().publicKey;
      final events = await _eventStore.queryEvents(
        RawEventQuery(
          kinds: const [NostrKind.loginItem],
          authors: [vaultPubkey],
          tagFilters: dTags != null ? [TagFilter('d', dTags)] : null,
        ),
      );

      if (events.isEmpty) {
        return ('', Uint8List(0), '');
      }

      final encryptedItems = LoginItemMapper.fromNostrEvents(events);
      final decryptedItems = <LoginItem>[];
      for (final item in encryptedItems) {
        try {
          decryptedItems.add(await _loginItemCryptoUsecase.decrypt(item));
        } catch (e) {
          log(e.toString(), name: 'ExportAccountsUsecase');
          continue;
        }
      }

      if (decryptedItems.isEmpty) {
        return ('', Uint8List(0), '');
      }

      final BackupPayload payload;
      try {
        payload = await _createPayload(decryptedItems, password: password);
      } catch (e) {
        throw ExportAccountsError(
          payload: ExportAccountsErrorType.encryptionFailed,
          parentError: e,
        );
      }

      final resolvedFileName = _fileName(fileName);
      final Uint8List zipBytes;
      final String filePath;
      try {
        zipBytes = BackupZipHelper.buildZipBytes(
          payload: payload,
          archivedFileName: archivedFileName,
          decryptScript: kAccountsDecryptBackupPy,
          readme: kAccountsBackupReadmeMd,
        );
        filePath = kIsWeb
            ? ''
            : await _writeToTempFile(zipBytes, resolvedFileName);
      } catch (e) {
        throw ExportAccountsError(
          payload: ExportAccountsErrorType.fileWriteFailed,
          parentError: e,
        );
      }

      if (zipBytes.isEmpty) {
        throw const ExportAccountsError(
          payload: ExportAccountsErrorType.fileWriteFailed,
        );
      }

      return (filePath, zipBytes, resolvedFileName);
    } on ExportAccountsError {
      rethrow;
    } catch (e) {
      throw ExportAccountsError(
        payload: ExportAccountsErrorType.unknown,
        parentError: e,
      );
    }
  }

  Future<BackupPayload> _createPayload(
    List<LoginItem> items, {
    required String password,
  }) async {
    final salt = BackupCryptoHelper.generateRandomBytes(16);
    final secretKey = await BackupCryptoHelper.deriveKey(
      password,
      salt,
      BackupCryptoHelper.defaultIterations,
    );
    final algorithm = BackupCryptoHelper.algorithm();

    final exportEvents = <Map<String, dynamic>>[];
    for (final item in items) {
      final plainJson = jsonEncode(
        LoginItemPayload(
          v: LoginItemPayload.supportedVersion,
          title: item.title,
          username: item.username,
          password: item.password,
          url: item.websiteUrl,
          notes: item.notes,
          updatedAt: item.updatedAt.millisecondsSinceEpoch ~/ 1000,
          image: item.image.isEmpty ? null : item.image,
          totp: item.totpSecret,
          rev: item.revision,
        ).toJson(),
      );

      exportEvents.add({
        'kind': NostrKind.loginItem,
        'id': '',
        'pubkey': '',
        'created_at': item.createdAt.millisecondsSinceEpoch ~/ 1000,
        'tags': LoginItemMapper.toTags(
          EncryptedLoginItem(
            eventId: item.eventId,
            dTag: item.dTag,
            encryptedPayload: '',
            createdAt: item.createdAt,
          ),
        ),
        'content': await BackupCryptoHelper.encryptField(
          plainJson,
          secretKey,
          algorithm,
        ),
        'sig': '',
      });
    }

    return BackupPayload(
      version: 1,
      encrypted: true,
      exportedAt: DateTime.now().toUtc().toIso8601String(),
      salt: HexToBytes.bytesToHex(salt),
      iterations: BackupCryptoHelper.defaultIterations,
      events: exportEvents,
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

    const filePrefix = 'accounts_backup_';
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return '$filePrefix$timestamp.zip';
  }
}
