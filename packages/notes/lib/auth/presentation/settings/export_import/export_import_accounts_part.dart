part of 'export_import_screen.dart';

mixin _ImportAccountsHelper {
  Future<void> onWillImportAccountsTap(BuildContext context) async {
    context.read<AccountsBackupBloc>().add(
      const AccountsBackupEvent.willImport(),
    );
  }

  Future<void> onImportAccounts(BuildContext context) async {
    final result =
        await showDialog<({String password, LoginItemImportPolicy policy})>(
          context: context,
          barrierDismissible: true,
          builder: (_) => const AccountsImportDialog(),
        );
    if (result == null) return;

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (context.mounted) {
        context.read<AccountsBackupBloc>().add(
          AccountsBackupEvent.import(
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

mixin _ExportAccountsHelper {
  Future<void> onWillExportAccountsTap(BuildContext context) async {
    context.read<AccountsBackupBloc>().add(
      const AccountsBackupEvent.willExport(),
    );
  }

  Future<void> onExportAccountsTap(BuildContext context) async {
    final result = await showDialog<AccountsExportPasswordDialogResult>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const AccountsExportPasswordDialog(),
    );
    if (result == null || !context.mounted) return;
    context.read<AccountsBackupBloc>().add(
      AccountsBackupEvent.export(
        password: result.password,
        fileName: result.fileName,
      ),
    );
  }
}
