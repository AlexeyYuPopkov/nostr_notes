import 'package:nostr_notes/app/l10n/app_localizations.dart';
import 'package:nostr_notes/auth/domain/model/nip44_exception.dart';
import 'package:nostr_notes/common/domain/error/app_error.dart';

mixin NoteDecryptErrorMessageMixin {
  String buildDecryptErrorMessage({
    required AppLocalizations l10n,
    required Object? error,
  }) {
    final base = l10n.notePreviewCannotDecryptDescription;
    if (error == null) {
      return base;
    }

    final reason = humanReadableDecryptReason(l10n: l10n, error: error);
    final details = error.toString().trim();

    return [
      base,
      '${l10n.notesListDecryptLikelyReasonLabel}: $reason',
      if (details.isNotEmpty) '${l10n.notesListDecryptDetailsLabel}: $details',
    ].join('\n\n');
  }

  String humanReadableDecryptReason({
    required AppLocalizations l10n,
    required Object error,
  }) {
    switch (error) {
      case InvalidMacNip44Exception():
        return l10n.notesListDecryptReasonWrongPin;
      case InvalidPaddingNip44Exception() ||
          InvalidPayloadEncodingNip44Exception() ||
          InvalidPayloadSizeNip44Exception() ||
          UnsupportedVersionNip44Exception() ||
          UnknownVersionNip44Exception():
        return l10n.notesListDecryptReasonCorruptedPayload;
      case InvalidConversationKeyLengthNip44Exception() ||
          InvalidNonceLengthNip44Exception() ||
          InvalidPlaintextLengthNip44Exception() ||
          InvalidPublicKeyNip44Exception():
        return l10n.notesListDecryptReasonInvalidParams;
      case NotUnlockedError():
        return l10n.notUnlocked;
      case NotAuthenticatedError():
        return l10n.authError;
      case AppError():
        return error.message.isNotEmpty
            ? error.message
            : l10n.commonUndefinedError;
      default:
        return l10n.commonUndefinedError;
    }
  }
}
