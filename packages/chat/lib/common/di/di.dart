import 'package:chat/auth/chat/data/contacts/contact_profiles.dart';
import 'package:chat/auth/chat/data/contacts/get_contact_usecase_impl.dart';
import 'package:chat/auth/chat/data/direct_messages/direct_message_crypto.dart';
import 'package:chat/auth/chat/data/direct_messages/direct_message_writer.dart';
import 'package:chat/auth/chat/data/direct_messages/direct_messages_reader.dart';
import 'package:chat/auth/chat/data/direct_messages/direct_messages_sync_usecase_impl.dart';
import 'package:chat/auth/chat/data/direct_messages/edit_chat_message_usecase_impl.dart';
import 'package:chat/auth/chat/data/direct_messages/get_chat_messages_usecase_impl.dart';
import 'package:chat/auth/chat/data/direct_messages/get_chat_rooms_usecase_impl.dart';
import 'package:chat/auth/chat/data/direct_messages/send_chat_message_usecase_impl.dart';
import 'package:chat/auth/chat/data/search_contacts/search_contacts_fetch_usecase_impl.dart';
import 'package:chat/auth/chat/data/search_contacts/search_contacts_get_usecase_impl.dart';
import 'package:chat/auth/chat/domain/usecase/direct_messages_sync_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/edit_chat_message_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/get_chat_messages_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/get_chat_rooms_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/get_contact_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/search_contacts_fetch_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/search_contacts_get_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/send_chat_message_usecase.dart';
import 'package:chat/auth/settings/data/profile/get_current_profile_usecase_impl.dart';
import 'package:chat/auth/settings/data/profile/update_profile_usecase_impl.dart';
import 'package:chat/auth/settings/domain/usecase/get_current_profile_usecase.dart';
import 'package:chat/auth/settings/domain/usecase/update_profile_usecase.dart';
import 'package:chat/common/domain/usecase/auth_usecase.dart';
import 'package:chat/common/domain/usecase/session_usecase.dart';
import 'package:common/data/repo/key_tool_repository_impl.dart';
import 'package:common/data/repo/secure_storage_impl.dart';
import 'package:common/domain/repo/key_tool_repository.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/database/daos/nostr_event_dao.dart';
import 'package:common/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:common/services/event_store/drift_event_store.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:common/services/outbox/outbox_publisher.dart';
import 'package:common/tools/app_worker/app_worker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:common/domain/repo/secure_storage.dart';
import 'package:common/domain/usecases/get_relays_usecase.dart';
import 'package:common/domain/usecases/relays_list_repo_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:nostr/nostr_client/async_fetcher.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr/nostr_client/nostr_relay.dart';
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
    GetIt.I.registerLazySingleton<AppDatabase>(
      AppDatabase.new,
      dispose: (db) => db.close(),
    );
    GetIt.I.registerLazySingleton<RawEventStore>(
      () => DriftEventStore(dao: NostrEventDao(GetIt.I.get())),
    );
    GetIt.I.registerLazySingleton<OutboxDaoInterface>(
      () => GetIt.I.get<AppDatabase>().outboxDao,
    );
    GetIt.I.registerLazySingleton<NostrClient>(
      () => NostrClient(
        batchParser: (batch, relayUrl) => AppWorker.instance.compute(
          params: (batch, relayUrl),
          callback: NostrRelayEventMapper.parseBatch,
        ),
      ),
      dispose: (client) => client.disconnectAndDispose(),
    );
    GetIt.I.registerLazySingleton<Connectivity>(Connectivity.new);
    GetIt.I.registerLazySingleton<OutboxPublisher>(
      () => OutboxPublisher(
        outboxDao: GetIt.I.get(),
        rawEventStore: GetIt.I.get(),
        relaysListRepo: GetIt.I.get(),
        client: GetIt.I.get(),
        connectivity: GetIt.I.get(),
      ),
      dispose: (publisher) => publisher.dispose(),
    );
    _registerDirectMessages();
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
    GetIt.I.registerFactory<GetCurrentProfileUsecase>(
      () => GetCurrentProfileUsecaseImpl(
        sessionUsecase: GetIt.I.get(),
        eventStore: GetIt.I.get(),
        client: GetIt.I.get(),
        asyncFetcher: AsyncFetcher(client: GetIt.I.get()),
        relaysListRepo: GetIt.I.get(),
      ),
    );
    GetIt.I.registerFactory<UpdateProfileUsecase>(
      () => UpdateProfileUsecaseImpl(
        sessionUsecase: GetIt.I.get(),
        eventStore: GetIt.I.get(),
        client: GetIt.I.get(),
        relaysListRepo: GetIt.I.get(),
      ),
    );
  }

  static void _registerDirectMessages() {
    GetIt.I.registerLazySingleton<DirectMessageCrypto>(DirectMessageCrypto.new);
    GetIt.I.registerLazySingleton<DirectMessagesSyncUsecase>(
      () => DirectMessagesSyncUsecaseImpl(
        sessionUsecase: GetIt.I.get(),
        client: GetIt.I.get(),
        relaysListRepo: GetIt.I.get(),
        eventStore: GetIt.I.get(),
        outboxPublisher: GetIt.I.get(),
      ),
      dispose: (sync) => (sync as DirectMessagesSyncUsecaseImpl).dispose(),
    );
    GetIt.I.registerFactory<DirectMessagesReader>(
      () => DirectMessagesReader(
        eventStore: GetIt.I.get(),
        outboxDao: GetIt.I.get(),
        crypto: GetIt.I.get(),
      ),
    );
    GetIt.I.registerFactory<DirectMessageWriter>(
      () => DirectMessageWriter(
        database: GetIt.I.get(),
        eventStore: GetIt.I.get(),
        outboxDao: GetIt.I.get(),
        crypto: GetIt.I.get(),
      ),
    );
    GetIt.I.registerFactory<ContactProfiles>(
      () => ContactProfiles(
        eventStore: GetIt.I.get(),
        client: GetIt.I.get(),
        asyncFetcher: AsyncFetcher(client: GetIt.I.get()),
        relaysListRepo: GetIt.I.get(),
      ),
    );
    GetIt.I.registerFactory<GetChatRoomsUsecase>(
      () => GetChatRoomsUsecaseImpl(
        sessionUsecase: GetIt.I.get(),
        reader: GetIt.I.get(),
        sync: GetIt.I.get(),
        profiles: GetIt.I.get(),
      ),
    );
    GetIt.I.registerFactory<GetChatMessagesUsecase>(
      () => GetChatMessagesUsecaseImpl(
        sessionUsecase: GetIt.I.get(),
        reader: GetIt.I.get(),
        sync: GetIt.I.get(),
      ),
    );
    GetIt.I.registerFactory<GetContactUsecase>(
      () => GetContactUsecaseImpl(profiles: GetIt.I.get()),
    );
    GetIt.I.registerFactory<SendChatMessageUsecase>(
      () => SendChatMessageUsecaseImpl(
        sessionUsecase: GetIt.I.get(),
        writer: GetIt.I.get(),
      ),
    );
    GetIt.I.registerFactory<EditChatMessageUsecase>(
      () => EditChatMessageUsecaseImpl(
        sessionUsecase: GetIt.I.get(),
        eventStore: GetIt.I.get(),
        writer: GetIt.I.get(),
      ),
    );
  }

  static Future<void> dropAuthModules() async {
    if (GetIt.I.hasScope(_authScope)) {
      await GetIt.I.dropScope(_authScope);
    }
  }
}
