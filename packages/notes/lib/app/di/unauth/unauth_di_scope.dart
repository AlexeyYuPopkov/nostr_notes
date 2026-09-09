import 'dart:async';
import 'package:common/data/repo/relays_monitoring_usecase_impl.dart';
import 'package:common/domain/error/error_messages_provider.dart';
import 'package:common/domain/usecases/relays_monitoring_usecase.dart';
import 'package:common/tools/app_worker/app_worker.dart';
import 'package:di_storage/di_storage.dart';
import 'package:nostr/nostr_client/async_fetcher.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr/nostr_client/nostr_relay.dart';
import 'package:nostr/nostr_client/relays_monitor.dart';
import 'package:nostr_notes/app/data/theme_mode_repo_impl.dart';
import 'package:nostr_notes/app/domain/theme_mode_repo.dart';
import 'package:nostr_notes/auth/data/desktop_ratio_repo_impl.dart';
import 'package:nostr_notes/auth/data/is_first_launch_repo_impl.dart';
import 'package:nostr_notes/auth/data/notes_list_tab_repo_impl.dart';
import 'package:nostr_notes/auth/data/accounts_repo_impl.dart';
import 'package:nostr_notes/auth/data/pin_enabled_repo_impl.dart';
import 'package:nostr_notes/auth/data/pin_keyboard_type_repo_impl.dart';
import 'package:common/domain/usecases/relays_list_repo_impl.dart';
import 'package:nostr_notes/auth/domain/repo/accounts_repo.dart';
import 'package:nostr_notes/auth/domain/repo/desktop_ratio_repo.dart';
import 'package:nostr_notes/auth/domain/repo/is_first_launch_repo.dart';
import 'package:nostr_notes/auth/domain/repo/notes_list_tab_repo.dart';
import 'package:nostr_notes/auth/domain/repo/pin_enabled_repo.dart';
import 'package:nostr_notes/auth/domain/repo/pin_keyboard_type_repo.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:common/data/error/error_messages_provider_impl.dart';
import 'package:common/data/repo/app_lifecycle_listener_datasource.dart';
import 'package:nostr_notes/common/data/biometric_datasource_impl.dart';
import 'package:common/data/repo/key_tool_repository_impl.dart';
import 'package:common/presentation/tools/root_context_provider/root_context_provider.dart';
import 'package:common/data/repo/secure_storage_impl.dart';
import 'package:common/domain/repo/key_tool_repository.dart';
import 'package:nostr_notes/common/data/usecases/get_user_usecase_impl.dart';
import 'package:common/domain/repo/app_lifecycle_listener_repository.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/pin_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/verification_usecase.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';
import 'package:nostr_notes/common/domain/usecase/get_user_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads `.instance` off [wrapped] via dynamic dispatch and returns it if
/// it's a [T] — used to unwrap di_storage's internal (non-exported)
/// `DiStorageEntry` without depending on its type. Returns null if
/// [wrapped] has no `.instance` getter or it isn't a [T].
///
/// di_storage 2.0.1 is inconsistent about what `onRemove` receives:
/// `DiStorage.removeScope` (used by production teardown, e.g.
/// `Di.removeUnauthModules`) passes the resolved instance directly, but
/// `DiStorage.remove`/`.removeAll` (what most tests' tearDown calls) pass
/// the internal wrapper instead — so every `onRemove` below has to handle
/// both shapes to actually run under test.
T? _tryGetInstance<T>(dynamic wrapped) {
  try {
    final instance = wrapped.instance;
    return instance is T ? instance : null;
  } catch (_) {
    return null;
  }
}

final class UnauthDiScope extends DiScope {
  final SharedPreferences prefs;

  const UnauthDiScope({required this.prefs});

  @override
  void bind(DiStorage di) {
    di.bind<ThemeModeRepo>(
      () => ThemeModeRepoImpl(prefs),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    di.bind<IsFirstLaunchRepo>(
      () => IsFirstLaunchRepoImpl(prefs),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<RelaysListRepo>(
      () => RelaysListRepoImpl(prefs),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    di.bind<PinKeyboardTypeRepo>(
      () => PinKeyboardTypeRepoImpl(prefs),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<PinEnabledRepo>(
      () => PinEnabledRepoImpl(prefs),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<AccountsRepo>(
      () => AccountsRepoImpl(prefs),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<DesktopRatioRepo>(
      () => DesktopRatioRepoImpl(prefs),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<NotesListTabRepo>(
      () => NotesListTabRepoImpl(prefs),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    di.bind<ErrorMessagesProvider>(
      () => ErrorMessagesProviderImpl(
        rootContextProvider: RootContextProvider.instance,
      ),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    di.bind<KeyToolRepository>(
      () => const KeyToolRepositoryImpl(),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    di.bind<SessionUsecase>(
      () => SessionUsecase(),
      module: this,
      lifeTime: const LifeTime.single(),
      onRemove: (e) {
        if (e is SessionUsecase) {
          e.dispose();
        }
      },
    );

    di.bind<AuthUsecase>(
      () => AuthUsecase(
        secureStorage: SecureStorageImpl(),
        sessionUsecase: di.resolve(),
        keyToolRepository: di.resolve(),
        relaysListRepo: di.resolve(),
        accountsRepo: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    di.bind<PinUsecase>(
      () => PinUsecase(sessionUsecase: di.resolve()),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    // di.bind<BlurScreenUsecase>(
    //   () => BlurScreenUsecase(authUsecase: di.resolve()),
    //   module: this,
    //   lifeTime: const LifeTime.single(),
    //   onRemove: (e) {
    //     if (e is BlurScreenUsecase) {
    //       e.dispose();
    //     }
    //   },
    // );

    di.bind<AppLifecycleListenerRepository>(
      () => AppLifecycleListenerDatasource(),
      module: this,
      lifeTime: const LifeTime.single(),
      onRemove: (e) {
        final instance = e is AppLifecycleListenerDatasource
            ? e
            : _tryGetInstance<AppLifecycleListenerDatasource>(e);
        instance?.dispose();
      },
    );

    di.bind<VerificationUsecase>(
      () => VerificationUsecase(
        biometricRepository: BiometricDatasourceImpl(),
        appLifecycleListenerRepository: di.resolve(),
        authUsecase: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.single(),
      onRemove: (e) {
        final instance = e is VerificationUsecase
            ? e
            : _tryGetInstance<VerificationUsecase>(e);
        instance?.dispose();
      },
    );
  }
}

final class NostrModule extends DiScope {
  const NostrModule();

  @override
  void bind(DiStorage di) {
    di.bind<NostrClient>(
      () => NostrClient(
        batchParser: (batch, relayUrl) => AppWorker.instance.compute(
          params: (batch, relayUrl),
          callback: NostrRelayEventMapper.parseBatch,
        ),
      ),
      module: this,
      lifeTime: const LifeTime.single(),
      // Without this, every hot restart (main() reruns bindUnauthModules,
      // which removes and rebinds this scope) drops the old NostrClient
      // instance without ever closing its relay sockets — they leak for
      // the rest of the debug session instead of disconnecting.
      onRemove: (e) {
        final instance = e is NostrClient ? e : _tryGetInstance<NostrClient>(e);
        instance?.disconnectAndDispose();
      },
    );

    di.bind<AsyncFetcher>(
      () => AsyncFetcher(client: di.resolve()),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<GetUserUsecase>(
      () => GetUserUsecaseImpl(
        asyncFetcher: di.resolve(),
        rawEventStore: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<RelaysMonitor>(
      () => RelaysMonitor(client: di.resolve()),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    // Disposing this transitively disposes the RelaysMonitor it wraps
    // (see RelaysMonitoringUsecaseImpl.dispose), so only this binding
    // needs an onRemove.
    di.bind<RelaysMonitoringUsecase>(
      () => RelaysMonitoringUsecaseImpl(
        monitor: di.resolve(),
        lifecycle: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.single(),
      onRemove: (e) {
        final instance = e is RelaysMonitoringUsecaseImpl
            ? e
            : _tryGetInstance<RelaysMonitoringUsecaseImpl>(e);
        instance?.dispose();
      },
    );
  }
}

final class CryptoDiModule extends DiScope {
  const CryptoDiModule();

  @override
  FutureOr<void> bind(DiStorage di) async {
    final cryptoService = CryptoService.create();

    di.bind<CryptoService>(
      () => cryptoService,
      module: this,
      lifeTime: const LifeTime.single(),
      onRemove: (e) {
        if (e is CryptoService) {
          e.dispose();
        }
      },
    );

    di.bind<ExtraDerivation>(
      () => ExtraDerivation(
        cryptoService: di.resolve(),
        sessionUsecase: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    return cryptoService.init();
  }
}
