import 'package:chat/auth/settings/domain/usecase/get_current_profile_usecase.dart';
import 'package:chat/auth/settings/domain/usecase/update_profile_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'fake_profile_usecases.dart';

/// Usage: And my profile is named {'Alice'}
///
/// Relays accept updates unless `no relay accepts my profile` says otherwise.
Future<void> myProfileIsNamed(WidgetTester tester, String name) async {
  final store = FakeProfileStore(name: name);
  GetIt.I.registerSingleton(store);
  addTearDown(store.close);

  GetIt.I.unregister<GetCurrentProfileUsecase>();
  GetIt.I.registerSingleton<GetCurrentProfileUsecase>(
    FakeGetCurrentProfileUsecase(store),
  );

  GetIt.I.unregister<UpdateProfileUsecase>();
  GetIt.I.registerSingleton<UpdateProfileUsecase>(
    FakeUpdateProfileUsecase(store),
  );
}
