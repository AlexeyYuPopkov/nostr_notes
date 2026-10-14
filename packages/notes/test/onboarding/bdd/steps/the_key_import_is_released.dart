import 'package:di_storage/di_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/common/domain/usecase/keys_backup/import_keys_usecase.dart';
import 'package:notes_test_kit/pump_helpers.dart';

import 'gated_import_keys_usecase.dart';

/// Usage: the key import is released
///
/// Needs `the key import waits until released` earlier in the scenario.
Future<void> theKeyImportIsReleased(WidgetTester tester) async {
  final usecase = DiStorage.shared.resolve<ImportKeysUsecase>();
  (usecase as GatedImportKeysUsecase).release();
  await PumpHelpers.pumpUntilIdle(tester);
}
