import 'package:di_storage/di_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:nostr_notes/services/backup_files/file_share_service.dart';

mixin ShareFileHelper {
  /// Returns whether the file reached the user (shared, saved or downloaded).
  Future<bool> shareFile(
    String filePath,
    Uint8List bytes,
    String fileName,
    BuildContext context, {
    String Function(Localization l10n)? successMessage,
  }) async {
    final resolveSuccessMessage =
        successMessage ?? (l10n) => l10n.exportImportExportSuccess;

    final FileShareService fileShareService = DiStorage.shared.resolve();
    final outcome = await fileShareService.share(
      filePath: filePath,
      bytes: bytes,
      fileName: fileName,
    );

    // On web share_plus falls back to a browser download and reports it as
    // unavailable, yet the file did reach the user.
    final delivered =
        outcome == FileShareOutcome.shared ||
        (kIsWeb && outcome == FileShareOutcome.unavailable);

    if (!context.mounted) return delivered;

    final message = switch (outcome) {
      FileShareOutcome.shared => resolveSuccessMessage(context.l10n),
      FileShareOutcome.dismissed => null,
      FileShareOutcome.unavailable =>
        kIsWeb
            ? context.l10n.exportImportWebDownloaded
            : context.l10n.exportImportShareUnavailable,
    };
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    return delivered;
  }
}
