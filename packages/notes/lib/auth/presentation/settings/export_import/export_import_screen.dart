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
import 'package:nostr_notes/auth/presentation/settings/export_import/bloc/export_import_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import/bloc/export_import_state.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/settings_screen_routes.dart';
import 'package:nostr_notes/auth/presentation/tools/share_file_helper.dart';
import 'package:nostr_notes/l10n/localization.dart';

import 'bloc/export_import_event.dart';
import 'export_password_dialog.dart';

part 'export_inport_part.dart';
part 'import_dialog_part.dart';

final class ExportImportScreen extends StatelessWidget {
  const ExportImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProgressHudWidgetContent(
      child: BlocProvider(
        create: (_) => ExportImportBloc(),
        child: const _ExportImportView(),
      ),
    );
  }
}

final class _ExportImportView extends StatelessWidget
    with DialogHelper, _ExportHelper, _ImportHelper, ShareFileHelper {
  const _ExportImportView();

  void _listener(BuildContext context, ExportImportState state) async {
    final hud = ProgressHud.of(context);
    hud?.setLoading(isLoading: state is LoadingState);

    final l10n = context.l10n;

    switch (state) {
      case SuccessState(:final filePath, :final bytes, :final fileName):
        shareFile(filePath, bytes, fileName, context);
        break;
      case ImportSuccessState():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.exportImportImportSuccess)));

        RouteHandler.of(context)?.onRoute(const CloseSettingsRoute(), context);
        break;
      case ErrorState(:final error):
        await showError(
          context,
          error: error,
          messageBuilder: (err) => _errorMessage(l10n, err),
        );
        break;
      case IdleState():
        break;
      case LoadingState():
        hud?.vm.progress = state.progress;
        break;
      case WillImport():
        onImport(context);
        break;
      case WillExport():
        onExportTap(context);
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<ExportImportBloc, ExportImportState>(
      listener: _listener,
      builder: (context, state) {
        final isLoading = state is LoadingState;

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
                  trailing: const Icon(Icons.upload, size: Sizes.iconMedium),
                  onTap: isLoading ? null : () => onWillExportTap(context),
                ),
                SettingsItemTile(
                  title: Text(l10n.exportImportItemImportTitle),
                  subtitle: l10n.exportImportItemImportSubtitle,
                  position: .last,
                  trailing: const Icon(Icons.download, size: Sizes.iconMedium),
                  onTap: isLoading ? null : () => onWillImportTap(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
