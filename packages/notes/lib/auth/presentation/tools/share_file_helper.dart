import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:share_plus/share_plus.dart';

mixin ShareFileHelper {
  Future<void> shareFile(
    String filePath,
    Uint8List bytes,
    String fileName,
    BuildContext context,
  ) async {
    final xFile = kIsWeb
        ? XFile.fromData(bytes, name: fileName, mimeType: 'application/zip')
        : XFile(filePath);
    final result = await SharePlus.instance.share(ShareParams(files: [xFile]));

    if (!context.mounted) return;

    switch (result.status) {
      case ShareResultStatus.success:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.exportImportExportSuccess)),
        );
        break;
      case ShareResultStatus.dismissed:
        break;
      case ShareResultStatus.unavailable:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.exportImportShareUnavailable)),
        );
        break;
    }
  }
}
