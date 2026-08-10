import 'package:di_storage/di_storage.dart';
import 'package:nostr_notes/auth/data/login_items/delete_login_item_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/export_accounts_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/get_login_item_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/import_accounts_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/login_item_crypto_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/save_login_item_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/sync_login_items_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/vault_identity_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/watch_login_items_usecase_impl.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/delete_login_item_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/export_accounts_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/get_login_item_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/import_accounts_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/login_item_crypto_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/save_login_item_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/sync_login_items_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/vault_identity_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/watch_login_items_usecase.dart';

/// Bindings for the login items ("account notes") feature. Bound and removed
/// together with the auth scope; see `AppDi.bindAuthModules`.
final class LoginItemsDiScope extends DiScope {
  const LoginItemsDiScope();

  @override
  void bind(DiStorage di) {
    di.bind<VaultIdentityUsecase>(
      () => VaultIdentityUsecaseImpl(sessionUsecase: di.resolve()),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    di.bind<LoginItemCryptoUsecase>(
      () => LoginItemCryptoUsecaseImpl(
        cryptoService: di.resolve(),
        sessionUsecase: di.resolve(),
        extraDerivation: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    di.bind<SaveLoginItemUsecase>(
      () => SaveLoginItemUsecaseImpl(
        eventStore: di.resolve(),
        outboxDao: di.resolve(),
        vaultIdentityUsecase: di.resolve(),
        loginItemCryptoUsecase: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<WatchLoginItemsUsecase>(
      () => WatchLoginItemsUsecaseImpl(
        eventStore: di.resolve(),
        vaultIdentityUsecase: di.resolve(),
        loginItemCryptoUsecase: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<GetLoginItemUsecase>(
      () => GetLoginItemUsecaseImpl(
        eventStore: di.resolve(),
        vaultIdentityUsecase: di.resolve(),
        loginItemCryptoUsecase: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<DeleteLoginItemUsecase>(
      () => DeleteLoginItemUsecaseImpl(
        eventStore: di.resolve(),
        outboxDao: di.resolve(),
        vaultIdentityUsecase: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<SyncLoginItemsUsecase>(
      () => SyncLoginItemsUsecaseImpl(
        client: di.resolve(),
        eventStore: di.resolve(),
        relaysListRepo: di.resolve(),
        vaultIdentityUsecase: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<ExportAccountsUsecase>(
      () => ExportAccountsUsecaseImpl(
        eventStore: di.resolve(),
        vaultIdentityUsecase: di.resolve(),
        loginItemCryptoUsecase: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<ImportAccountsUsecase>(
      () => ImportAccountsUsecaseImpl(
        vaultIdentityUsecase: di.resolve(),
        getLoginItemUsecase: di.resolve(),
        saveLoginItemUsecase: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );
  }
}
