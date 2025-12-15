import 'dart:async';
import 'package:di_storage/di_storage.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:nostr_notes/common/data/error/error_messages_provider_impl.dart';
import 'package:nostr_notes/common/data/key_tool_repository_impl.dart';
import 'package:nostr_notes/common/data/root_context_provider/root_context_provider.dart';
import 'package:nostr_notes/common/data/secure_storage_impl.dart';
import 'package:nostr_notes/common/domain/error/error_messages_provider.dart';
import 'package:nostr_notes/common/domain/repository/key_tool_repository.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/pin_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';

final class UnauthDiScope extends DiScope {
  const UnauthDiScope();

  @override
  void bind(DiStorage di) {
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
      onRemove: (e) => (e as SessionUsecase).dispose(),
    );

    di.bind<AuthUsecase>(
      () => AuthUsecase(
        secureStorage: SecureStorageImpl(),
        sessionUsecase: di.resolve(),
        keyToolRepository: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    di.bind<PinUsecase>(
      () => PinUsecase(sessionUsecase: di.resolve()),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    // di.bind<AesCbcRepo>(
    //   () => AesCbcRepo.create(),
    //   module: this,
    //   lifeTime: const LifeTime.single(),
    // );
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
