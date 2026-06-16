part of 'export_import_screen.dart';

mixin _ImportHelper {
  Future<void> onWillImportTap(BuildContext context) async {
    context.read<ExportImportBloc>().add(const ExportImportEvent.willImport());
  }

  Future<void> onImport(BuildContext context) async {
    final result = await showDialog<({String password, ImportPolicy policy})>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _ImportAlertContent(),
    );
    if (result == null) return;

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (context.mounted) {
        context.read<ExportImportBloc>().add(
          ExportImportEvent.import(
            file: file,
            password: result.password,
            policy: result.policy,
          ),
        );
      }
    } catch (e) {
      log('FilePicker.pickFile: ${e.toString()}', name: 'ExportImportScreen');
    }
  }
}

mixin _ExportHelper {
  Future<void> onWillExportTap(BuildContext context) async {
    context.read<ExportImportBloc>().add(const ExportImportEvent.willExport());
  }

  Future<void> onExportTap(BuildContext context) async {
    final result = await showDialog<ExportPasswordDialogResult>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const ExportPasswordDialog(),
    );
    if (result == null || !context.mounted) return;
    context.read<ExportImportBloc>().add(
      ExportImportEvent.export(
        password: result.password,
        fileName: result.fileName,
      ),
    );
  }
}
