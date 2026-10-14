import 'package:di_storage/di_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/common/domain/usecase/keys_backup/import_keys_usecase.dart';

import 'gated_import_keys_usecase.dart';

/// Usage: the key import waits until released
///
/// Pair with `the key import is released`.
Future<void> theKeyImportWaitsUntilReleased(WidgetTester tester) async {
  final di = DiStorage.shared;
  final gated = GatedImportKeysUsecase(di.resolve<ImportKeysUsecase>());
  di
    ..remove<ImportKeysUsecase>()
    ..bind<ImportKeysUsecase>(
      () => gated,
      module: null,
      lifeTime: const LifeTime.single(),
    );
  addTearDown(gated.release);
}
