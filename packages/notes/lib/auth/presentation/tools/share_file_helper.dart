import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:share_plus/share_plus.dart';

mixin ShareFileHelper {
  Future<void> shareFile(
    String filePath,
    Uint8List bytes,
    String fileName,
    BuildContext context, {
    String Function(Localization l10n)? successMessage,
  }) async {
    final resolveSuccessMessage =
        successMessage ?? (l10n) => l10n.exportImportExportSuccess;

    if (!kIsWeb && _isDesktop) {
      await _saveFileDesktop(bytes, fileName, context, resolveSuccessMessage);
      return;
    }

    final xFile = kIsWeb
        ? XFile.fromData(bytes, name: fileName, mimeType: 'application/zip')
        : XFile(filePath);
    final result = await SharePlus.instance.share(ShareParams(files: [xFile]));

    if (!context.mounted) return;

    switch (result.status) {
      case ShareResultStatus.success:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resolveSuccessMessage(context.l10n))),
        );
        break;
      case ShareResultStatus.dismissed:
        break;
      case ShareResultStatus.unavailable:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              kIsWeb
                  ? context.l10n.exportImportWebDownloaded
                  : context.l10n.exportImportShareUnavailable,
            ),
          ),
        );
        break;
    }
  }

  bool get _isDesktop =>
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  Future<void> _saveFileDesktop(
    Uint8List bytes,
    String fileName,
    BuildContext context,
    String Function(Localization l10n) resolveSuccessMessage,
  ) async {
    final savedPath = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (!context.mounted) return;
    if (savedPath == null) return; // user cancelled

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(resolveSuccessMessage(context.l10n))),
    );
  }
}
