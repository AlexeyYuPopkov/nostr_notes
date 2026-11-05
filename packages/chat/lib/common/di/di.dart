import 'package:chat/auth/chat/data/fake_chats_repo.dart';
import 'package:chat/auth/chat/data/search_contacts/search_contacts_fetch_usecase_impl.dart';
import 'package:chat/auth/chat/data/search_contacts/search_contacts_get_usecase_impl.dart';
import 'package:chat/auth/chat/domain/repo/chats_repo.dart';
import 'package:chat/auth/chat/domain/usecase/search_contacts_fetch_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/search_contacts_get_usecase.dart';
import 'package:chat/common/domain/usecase/auth_usecase.dart';
import 'package:chat/common/domain/usecase/session_usecase.dart';
import 'package:common/data/repo/key_tool_repository_impl.dart';
import 'package:common/data/repo/secure_storage_impl.dart';
import 'package:common/domain/repo/key_tool_repository.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/database/daos/nostr_event_dao.dart';
import 'package:common/services/event_store/drift_event_store.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:common/domain/repo/secure_storage.dart';
import 'package:common/domain/usecases/get_relays_usecase.dart';
import 'package:common/domain/usecases/relays_list_repo_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:nostr/nostr_client/async_fetcher.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Di {
  static const _unauthScope = 'unauth-scope';
  static const _authScope = 'auth-scope';

  static Future<void> registerUnauthModules() async {
    final prefs = await SharedPreferences.getInstance();

    GetIt.I.pushNewScope(scopeName: _unauthScope);

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

    GetIt.I.registerLazySingleton<AuthUsecase>(
      () => AuthUsecase(
        secureStorage: GetIt.I.get(),
        sessionUsecase: GetIt.I.get(),
        keyToolRepository: GetIt.I.get(),
        relaysListRepo: GetIt.I.get(),
      ),
    );

    GetIt.I.registerFactory<GetRelaysUsecase>(
      () => GetRelaysUsecase(relaysListRepo: GetIt.I.get()),
    );
  }

  static Future<void> dropUnauthModules() {
    return GetIt.I.dropScope(_unauthScope);
  }

  static void registerAuthModules() {
    if (GetIt.I.hasScope(_authScope)) {
      return;
    }
    GetIt.I.pushNewScope(scopeName: _authScope);
    GetIt.I.registerLazySingleton<ChatsRepo>(FakeChatsRepo.new);
    GetIt.I.registerLazySingleton<AppDatabase>(
      AppDatabase.new,
      dispose: (db) => db.close(),
    );
    GetIt.I.registerLazySingleton<RawEventStore>(
      () => DriftEventStore(dao: NostrEventDao(GetIt.I.get())),
    );
    GetIt.I.registerLazySingleton<NostrClient>(
      NostrClient.new,
      dispose: (client) => client.disconnectAndDispose(),
    );
    GetIt.I.registerFactory<SearchContactsFetchUsecase>(
      () => SearchContactsFetchUsecaseImpl(
        client: GetIt.I.get(),
        asyncFetcher: AsyncFetcher(client: GetIt.I.get()),
        relaysListRepo: GetIt.I.get(),
        eventStore: GetIt.I.get(),
      ),
    );
    GetIt.I.registerFactory<SearchContactsGetUsecase>(
      () => SearchContactsGetUsecaseImpl(eventStore: GetIt.I.get()),
    );
  }

  static Future<void> dropAuthModules() async {
    if (GetIt.I.hasScope(_authScope)) {
      await GetIt.I.dropScope(_authScope);
    }
  }
}
