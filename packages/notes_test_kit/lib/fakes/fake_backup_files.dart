import 'dart:typed_data';

import 'package:di_storage/di_storage.dart';
import 'package:nostr_notes/services/backup_files/backup_file_picker.dart';
import 'package:nostr_notes/services/backup_files/file_share_service.dart';

final class FakeFileShareService implements FileShareService {
  final shared = <({String fileName, Uint8List bytes})>[];

  @override
  Future<FileShareOutcome> share({
    required String filePath,
    required Uint8List bytes,
    required String fileName,
  }) async {
    shared.add((fileName: fileName, bytes: bytes));
    return FileShareOutcome.shared;
  }
}

final class FakeBackupFilePicker implements BackupFilePicker {
  PickedBackupFile? nextFile;

  @override
  Future<PickedBackupFile?> pickZip() async => nextFile;
}

FakeFileShareService get fakeFileShare =>
    DiStorage.shared.resolve<FileShareService>() as FakeFileShareService;

FakeBackupFilePicker get fakeFilePicker =>
    DiStorage.shared.resolve<BackupFilePicker>() as FakeBackupFilePicker;
