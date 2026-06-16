part of 'export_import_screen.dart';

mixin _ImportHelper {
  Future<void> _onWillImportTap(BuildContext context) async {
    context.read<ExportImportBloc>().add(const ExportImportEvent.willImport());
  }

  Future<void> _onImport(BuildContext context) async {
    final result = await showDialog<({String password, ImportPolicy policy})>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _ImportAlertContent(),
    );
    if (result == null) return;

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
  }
}
