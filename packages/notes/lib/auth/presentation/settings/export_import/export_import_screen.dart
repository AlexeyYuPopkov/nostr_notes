import 'dart:developer';

import 'package:common/app/theme/sizes.dart';
import 'package:common/l10n/localization.dart';
import 'package:common/presentation/dialogs/dialog_button.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:common/presentation/widgets/onboarding_text_field.dart';
import 'package:common/presentation/widgets/progress_hud/progress_hud.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/auth/domain/usecase/export_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/import_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/export_accounts_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/import_accounts_usecase.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import/bloc/export_import_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import/bloc/export_import_state.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import_accounts/accounts_export_password_dialog.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import_accounts/accounts_import_dialog.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import_accounts/bloc/accounts_backup_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import_accounts/bloc/accounts_backup_event.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import_accounts/bloc/accounts_backup_state.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/settings_screen_routes.dart';
import 'package:nostr_notes/auth/presentation/tools/share_file_helper.dart';
import 'package:nostr_notes/l10n/localization.dart';

import 'bloc/export_import_event.dart';
import 'export_password_dialog.dart';

part 'export_import_accounts_part.dart';
part 'export_inport_part.dart';
part 'import_dialog_part.dart';

final class ExportImportScreen extends StatelessWidget {
  const ExportImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProgressHudWidgetContent(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ExportImportBloc()),
          BlocProvider(create: (_) => AccountsBackupBloc()),
        ],
        child: const _ExportImportView(),
      ),
    );
  }
}

final class _ExportImportView extends StatelessWidget
    with
        DialogHelper,
        _ExportHelper,
        _ImportHelper,
        _ExportAccountsHelper,
        _ImportAccountsHelper,
        ShareFileHelper {
  const _ExportImportView();

  void _listener(BuildContext context, ExportImportState state) async {
    final hud = ProgressHud.of(context);
    hud?.setLoading(isLoading: state is LoadingState);

    final l10n = context.l10n;

    switch (state) {
      case LoadingState():
        break;
      case ErrorState(:final error):
        await showError(
          context,
          error: error,
          messageBuilder: (err) => _errorMessage(l10n, err),
        );
        break;
      case SuccessState(:final filePath, :final bytes, :final fileName):
        shareFile(filePath, bytes, fileName, context);
        break;
      case ImportSuccessState():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.exportImportImportSuccess)));

        RouteHandler.of(context)?.onRoute(const CloseSettingsRoute(), context);
        break;
      case IdleState():
        break;
      case WillImport():
        onImport(context);
        break;
      case WillExport():
        onExportTap(context);
        break;
    }
  }

  void _accountsListener(
    BuildContext context,
    AccountsBackupState state,
  ) async {
    final hud = ProgressHud.of(context);
    hud?.setLoading(isLoading: state is LoadingAccountsState);

    final l10n = context.l10n;

    switch (state) {
      case ErrorAccountsState(:final error):
        await showError(
          context,
          error: error,
          messageBuilder: (err) => _accountsErrorMessage(l10n, err),
        );
        break;
      case SuccessAccountsState(:final filePath, :final bytes, :final fileName):
        shareFile(
          filePath,
          bytes,
          fileName,
          context,
          successMessage: (l10n) => l10n.accsBackupExportSuccess,
        );
        break;
      case ImportSuccessAccountsState():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.accsBackupImportSuccess)),
        );
        RouteHandler.of(context)?.onRoute(const CloseSettingsRoute(), context);
        break;
      case WillImportAccountsState():
        onImportAccounts(context);
        break;
      case WillExportAccountsState():
        onExportAccountsTap(context);
        break;
      case IdleAccountsState():
      case LoadingAccountsState():
        break;
    }
  }

  String? _errorMessage(Localization l10n, Object? error) {
    return switch (error) {
      ExportError(:final payload) => switch (payload) {
        ExportErrorType.noNotes => l10n.exportImportExportEmptyError,
        ExportErrorType.encryptionFailed =>
          l10n.exportImportExportEncryptionError,
        ExportErrorType.fileWriteFailed => l10n.exportImportExportFileError,
        ExportErrorType.unknown => null,
      },
      ImportError(:final payload) => switch (payload) {
        ImportErrorType.invalidFile => l10n.exportImportImportInvalidFileError,
        ImportErrorType.wrongPassword =>
          l10n.exportImportImportWrongPasswordError,
        ImportErrorType.notAuthenticated => l10n.exportImportImportAuthError,
        ImportErrorType.unknown => null,
        ImportErrorType.fileNotFound =>
          l10n.exportImportImportFileNotFoundError,
      },
      _ => null,
    };
  }

  String? _accountsErrorMessage(Localization l10n, Object? error) {
    return switch (error) {
      ExportAccountsError(:final payload) => switch (payload) {
        ExportAccountsErrorType.noAccounts => l10n.accsBackupExportEmptyError,
        ExportAccountsErrorType.passwordRequired =>
          l10n.accsBackupExportPasswordRequired,
        ExportAccountsErrorType.encryptionFailed =>
          l10n.exportImportExportEncryptionError,
        ExportAccountsErrorType.fileWriteFailed =>
          l10n.exportImportExportFileError,
        ExportAccountsErrorType.unknown => null,
      },
      ImportAccountsError(:final payload) => switch (payload) {
        ImportAccountsErrorType.invalidFile =>
          l10n.exportImportImportInvalidFileError,
        ImportAccountsErrorType.wrongPassword =>
          l10n.exportImportImportWrongPasswordError,
        ImportAccountsErrorType.passwordRequired =>
          l10n.accsBackupExportPasswordRequired,
        ImportAccountsErrorType.notAuthenticated =>
          l10n.exportImportImportAuthError,
        ImportAccountsErrorType.unknown => null,
        ImportAccountsErrorType.fileNotFound =>
          l10n.exportImportImportFileNotFoundError,
      },
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return MultiBlocListener(
      listeners: [
        BlocListener<ExportImportBloc, ExportImportState>(
          listener: _listener,
        ),
        BlocListener<AccountsBackupBloc, AccountsBackupState>(
          listener: _accountsListener,
        ),
      ],
      child: Builder(
        builder: (context) {
          final notesLoading =
              context.watch<ExportImportBloc>().state is LoadingState;
          final accountsLoading =
              context.watch<AccountsBackupBloc>().state is LoadingAccountsState;

          return Scaffold(
            appBar: AppBar(title: Text(l10n.exportImportScreenTitle)),
            body: SafeArea(
              child: ListView(
                children: [
                  SettingsItemTile(
                    title: Text(l10n.exportImportItemExportTitle),
                    subtitle: l10n.exportImportItemExportSubtitle,
                    sectionTitle: l10n.exportImportSectionDataTitle,
                    position: .first,
                    trailing: const Icon(
                      Icons.upload,
                      size: Sizes.iconMedium,
                    ),
                    onTap: notesLoading
                        ? null
                        : () => onWillExportTap(context),
                  ),
                  SettingsItemTile(
                    title: Text(l10n.exportImportItemImportTitle),
                    subtitle: l10n.exportImportItemImportSubtitle,
                    position: .last,
                    trailing: const Icon(
                      Icons.download,
                      size: Sizes.iconMedium,
                    ),
                    onTap: notesLoading
                        ? null
                        : () => onWillImportTap(context),
                  ),
                  SettingsItemTile(
                    title: Text(l10n.accsBackupItemExportTitle),
                    subtitle: l10n.accsBackupItemExportSubtitle,
                    sectionTitle: l10n.accsBackupSectionTitle,
                    position: .first,
                    trailing: const Icon(
                      Icons.upload,
                      size: Sizes.iconMedium,
                    ),
                    onTap: accountsLoading
                        ? null
                        : () => onWillExportAccountsTap(context),
                  ),
                  SettingsItemTile(
                    title: Text(l10n.accsBackupItemImportTitle),
                    subtitle: l10n.accsBackupItemImportSubtitle,
                    position: .last,
                    trailing: const Icon(
                      Icons.download,
                      size: Sizes.iconMedium,
                    ),
                    onTap: accountsLoading
                        ? null
                        : () => onWillImportAccountsTap(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
