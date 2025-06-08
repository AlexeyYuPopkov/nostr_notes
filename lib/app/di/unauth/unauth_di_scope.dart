import 'package:di_storage/di_storage.dart';
import 'package:nostr_notes/common/data/key_tool_repository_impl.dart';
import 'package:nostr_notes/common/data/secure_storage_impl.dart';
import 'package:nostr_notes/common/domain/repository/key_tool_repository.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/pin_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';

final class UnauthDiScope extends DiScope {
  const UnauthDiScope();

  @override
  void bind(DiStorage di) {
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
      lifeTime: const LifeTime.prototype(),
    );
    di.bind<PinUsecase>(
      () => PinUsecase(sessionUsecase: di.resolve()),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );
  }
}
