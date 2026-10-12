part of 'export_import_screen.dart';

mixin _ExportKeyHelper {
  Future<void> onExportKeyTap(BuildContext context) async {
    final bloc = context.read<KeysBackupBloc>();
    final result = await showDialog<BackupPasswordDialogResult>(
      context: context,
      builder: (_) => const BackupPasswordDialog.keysExport(),
    );
    if (result == null) return;
    bloc.add(
      KeysBackupEvent.export(
        password: result.password,
        fileName: result.fileName,
      ),
    );
  }
}
