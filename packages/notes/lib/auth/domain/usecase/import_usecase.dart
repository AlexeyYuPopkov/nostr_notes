import 'package:common/domain/error/app_error.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';

abstract interface class ImportUsecase {
  Future<void> importNotes({
    required String password,
    required String filePath,
    ImportPolicy policy = const ImportPolicy.mergeContent(),
    bool needsPublish = false,
  });
}

/// Resolves a per-note import collision: when a backup note shares its d-tag
/// (`kind:pubkey:d-tag` coordinate) with an already stored note, the policy
/// produces the single resulting note for that d-tag.
///
/// The result always keeps the original d-tag, so the event store replaces the
/// stored version natively via addressable-event (NIP-33) semantics — no relay
/// deletion is involved. When there is no collision ([existing] is `null`)
/// every policy returns the incoming note unchanged.
sealed class ImportPolicy {
  const ImportPolicy();

  /// Combine both notes: keep the existing content and append the imported one
  /// (labels from both are merged).
  const factory ImportPolicy.mergeContent() = MergeContent;

  /// On collision the imported note wins (overwrites the stored one).
  const factory ImportPolicy.keepIncoming() = KeepIncoming;

  /// On collision the stored note wins (the imported one is dropped).
  const factory ImportPolicy.keepExisting() = KeepExisting;

  Note apply(Note incoming, Note? existing);
}

final class MergeContent extends ImportPolicy {
  const MergeContent();

  static const separator = '\n\n## ------ Imported ------\n\n';

  @override
  Note apply(Note incoming, Note? existing) {
    if (existing == null) {
      return incoming;
    }
    return incoming.copyWith(
      content: '${existing.content}$separator${incoming.content}',
      labels: {...existing.labels, ...incoming.labels}.toList(),
    );
  }
}

final class KeepIncoming extends ImportPolicy {
  const KeepIncoming();

  @override
  Note apply(Note incoming, Note? existing) => incoming;
}

final class KeepExisting extends ImportPolicy {
  const KeepExisting();

  @override
  Note apply(Note incoming, Note? existing) => existing ?? incoming;
}

final class ImportError extends CustomError<ImportErrorType> {
  const ImportError({required super.payload, super.parentError, super.reason});
}

enum ImportErrorType {
  /// The file is missing, not a valid archive, or has an unsupported version.
  invalidFile,

  /// Decryption failed — wrong password or the backup is corrupted.
  wrongPassword,

  /// No unlocked session is available to re-encrypt the imported notes.
  notAuthenticated,

  /// Any other, unanticipated failure.
  unknown,
}
