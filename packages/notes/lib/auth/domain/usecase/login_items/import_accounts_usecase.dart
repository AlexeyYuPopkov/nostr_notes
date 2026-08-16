import 'dart:typed_data';

import 'package:common/domain/error/app_error.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';

abstract interface class ImportAccountsUsecase {
  /// Unlike [ImportUsecase] (notes), [password] is required and rejected if
  /// empty — mirrors [ExportAccountsUsecase] requiring one on export, so an
  /// accounts backup can never round-trip unencrypted.
  Future<void> importAccounts({
    required String password,
    String filePath,
    Uint8List? fileBytes,
    LoginItemImportPolicy policy = const LoginItemImportPolicy.keepNewest(),
  });
}

/// Resolves a per-account import collision: when a backup item shares its
/// d-tag with an already stored item, the policy produces the single
/// resulting item for that d-tag.
///
/// Unlike notes' `ImportPolicy`, there is no "merge" option — concatenating
/// two different passwords or usernames into one string isn't meaningful
/// for structured credential fields. [KeepNewestLoginItem] fills that role
/// instead: a safe, non-destructive default that picks whichever version
/// was actually edited more recently, using the same `updatedAt` the app
/// already tracks per item.
///
/// The result always keeps the original d-tag, so the event store replaces
/// the stored version natively via addressable-event (NIP-33) semantics.
/// When there is no collision ([existing] is `null`) every policy returns
/// the incoming item unchanged.
sealed class LoginItemImportPolicy {
  const LoginItemImportPolicy();

  /// On collision, whichever item was edited more recently wins.
  const factory LoginItemImportPolicy.keepNewest() = KeepNewestLoginItem;

  /// On collision the imported item wins (overwrites the stored one).
  const factory LoginItemImportPolicy.keepIncoming() = KeepIncomingLoginItem;

  /// On collision the stored item wins (the imported one is dropped).
  const factory LoginItemImportPolicy.keepExisting() = KeepExistingLoginItem;

  LoginItem apply(LoginItem incoming, LoginItem? existing);
}

final class KeepNewestLoginItem extends LoginItemImportPolicy {
  const KeepNewestLoginItem();

  @override
  LoginItem apply(LoginItem incoming, LoginItem? existing) {
    if (existing == null) return incoming;
    return incoming.updatedAt.isAfter(existing.updatedAt) ? incoming : existing;
  }
}

final class KeepIncomingLoginItem extends LoginItemImportPolicy {
  const KeepIncomingLoginItem();

  @override
  LoginItem apply(LoginItem incoming, LoginItem? existing) => incoming;
}

final class KeepExistingLoginItem extends LoginItemImportPolicy {
  const KeepExistingLoginItem();

  @override
  LoginItem apply(LoginItem incoming, LoginItem? existing) =>
      existing ?? incoming;
}

final class ImportAccountsError extends CustomError<ImportAccountsErrorType> {
  const ImportAccountsError({
    required super.payload,
    super.parentError,
    super.reason,
  });
}

enum ImportAccountsErrorType {
  /// The file is missing, not a valid archive, or has an unsupported
  /// version.
  invalidFile,

  fileNotFound,

  /// [ImportAccountsUsecase.importAccounts] was called with an empty
  /// password.
  passwordRequired,

  /// Decryption failed — wrong password or the backup is corrupted.
  wrongPassword,

  notAuthenticated,

  unknown,
}
