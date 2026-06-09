import 'package:di_storage/di_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/usecase/export_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/import_usecase.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import/bloc/export_import_data.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import/bloc/export_import_event.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import/bloc/export_import_state.dart';

final class ExportImportBloc
    extends Bloc<ExportImportEvent, ExportImportState> {
  ExportImportData get data => state.data;

  late final ExportUsecase _exportUsecase = DiStorage.shared.resolve();
  late final ImportUsecase _importUsecase = DiStorage.shared.resolve();

  ExportImportBloc()
    : super(ExportImportState.idle(data: ExportImportData.initial())) {
    on<ExportEvent>(_onExport);
    on<ImportEvent>(_onImport);
  }

  Future<void> _onExport(
    ExportEvent event,
    Emitter<ExportImportState> emit,
  ) async {
    emit(ExportImportState.loading(data: data));
    try {
      final filePath = await _exportUsecase.exportNotes(
        password: event.password,
        fileUri: '',
      );
      if (filePath.isEmpty) {
        emit(
          ExportImportState.error(
            data: data,
            error: const ExportError(payload: ExportErrorType.noNotes),
          ),
        );
        return;
      }
      emit(ExportImportState.success(data: data, filePath: filePath));
    } catch (e) {
      emit(ExportImportState.error(data: data, error: e));
    }
  }

  Future<void> _onImport(
    ImportEvent event,
    Emitter<ExportImportState> emit,
  ) async {
    emit(ExportImportState.loading(data: data));
    try {
      await _importUsecase.importNotes(
        password: event.password,
        filePath: event.filePath,
        policy: event.policy,
      );
      emit(ExportImportState.importSuccess(data: data));
    } catch (e) {
      emit(ExportImportState.error(data: data, error: e));
    }
  }
}
