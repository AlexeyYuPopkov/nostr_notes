import 'package:chat/common/domain/usecase/auth_usecase.dart';
import 'package:chat/common/domain/usecase/session_usecase.dart';
import 'package:common/data/repo/key_tool_repository_impl.dart';
import 'package:common/data/repo/secure_storage_impl.dart';
import 'package:common/domain/repo/key_tool_repository.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:common/domain/repo/secure_storage.dart';
import 'package:common/domain/usecases/relays_list_repo_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Di {
  static Future<void> registerUnauthModules() async {
    final prefs = await SharedPreferences.getInstance();
    GetIt.I.registerSingleton<RelaysListRepo>(
      RelaysListRepoImpl(prefs),
      dispose: (i) => i.dispose(),
    );
    GetIt.I.registerSingleton<SecureStorage>(SecureStorageImpl());
    GetIt.I.registerSingleton<SessionUsecase>(
      SessionUsecase(),
      dispose: (i) => i.dispose(),
    );
    GetIt.I.registerSingleton<KeyToolRepository>(KeyToolRepositoryImpl());

    GetIt.I.registerFactory(
      () => AuthUsecase(
        secureStorage: GetIt.I.get(),
        sessionUsecase: GetIt.I.get(),
        keyToolRepository: GetIt.I.get(),
        relaysListRepo: GetIt.I.get(),
      ),
    );
  }
}
