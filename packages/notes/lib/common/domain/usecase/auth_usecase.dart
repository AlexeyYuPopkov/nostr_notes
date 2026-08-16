import 'package:common/domain/error/app_error.dart';
import 'package:common/domain/repo/secure_storage.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr_notes/auth/domain/repo/accounts_repo.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:common/domain/repo/key_tool_repository.dart';

import 'session_usecase.dart';

final class AuthUsecase {
  static const String secureStorageKey = 'NostrNotes.Nsec';

  final SecureStorage _secureStorage;
  final SessionUsecase _sessionUsecase;
  final KeyToolRepository _keyToolRepository;
  final RelaysListRepo _relaysListRepo;
  final AccountsRepo _accountsRepo;

  AuthUsecase({
    required SecureStorage secureStorage,
    required SessionUsecase sessionUsecase,
    required KeyToolRepository keyToolRepository,
    required RelaysListRepo relaysListRepo,
    required AccountsRepo accountsRepo,
  }) : _secureStorage = secureStorage,
       _sessionUsecase = sessionUsecase,
       _keyToolRepository = keyToolRepository,
       _relaysListRepo = relaysListRepo,
       _accountsRepo = accountsRepo;

  static String accountStorageKey(String pubkey) => '$secureStorageKey.$pubkey';

  Stream<Session> get session => _sessionUsecase.sessionStream;
  Session get currentSession => _sessionUsecase.currentSession;

  Future<void> execute({required String nsec}) async {
    final userKeys = _keyToolRepository.getUserKeysWithNsec(nsec: nsec);
    await _persistAccount(userKeys);

    final currentSession = _sessionUsecase.currentSession;
    switch (currentSession) {
      case Unauth():
        _sessionUsecase.setSession(currentSession.toAuth(keys: userKeys));
        break;
      case Auth():
      case Unlocked():
        assert(
          false,
          'Session should not be Auth or Unlocked when setting a nsec',
        );
    }
  }

  /// Registers a new account while another one is active and switches the
  /// session to it. The session becomes [Auth] (locked), so the router sends
  /// the user to the PIN step to unlock the freshly added account.
  Future<void> addAccount({required String nsec}) async {
    final userKeys = _keyToolRepository.getUserKeysWithNsec(nsec: nsec);
    await _persistAccount(userKeys);

    _sessionUsecase.setSession(Auth(userKeys));
  }

  /// Activates a previously added account. The session becomes [Auth]
  /// (locked), so the router sends the user to the PIN step — unless
  /// [authologinIfPossible] is false, in which case a no-PIN account stays
  /// locked instead of silently auto-unlocking (see [logout]).
  Future<void> switchAccount({
    required String pubkey,
    bool authologinIfPossible = true,
  }) async {
    if (pubkey == _sessionUsecase.currentSession.pubkey) {
      return;
    }

    final privateKey = await _secureStorage.getValue(
      key: accountStorageKey(pubkey),
    );
    if (privateKey.isEmpty || validatePrivateKey(privateKey) != null) {
      await _accountsRepo.removeAccount(pubkey);
      throw const AppError.common(
        message: 'No stored key found for the account',
        reason: 'No stored key found for the account',
      );
    }

    final userKeys = _keyToolRepository.getUserKeysWithPrivateKey(
      privateKey: privateKey,
    );
    await _secureStorage.setValue(
      key: secureStorageKey,
      value: userKeys.privateKey,
    );

    _sessionUsecase.setSession(
      Auth(userKeys, authologinIfPossible: authologinIfPossible),
    );
  }

  /// Restores the session from the stored active key. Also used to re-lock
  /// an [Unlocked] session (e.g. after a failed biometry check): the result
  /// is always [Auth] or [Unauth], never [Unlocked].
  ///
  /// [authologinIfPossible] only ever *grants* auto-unlock — it can never
  /// take back an opt-out already recorded on the same account. Restoring
  /// is idempotent and happens from several places that know nothing about
  /// how the session got locked (app start, `OnboardingScreen`'s own
  /// `FutureBuilder`, biometry re-lock), so letting a redundant restore
  /// reset the flag would resurrect the auto-unlock the user just
  /// suppressed by tapping Exit.
  Future<Session> restore({bool authologinIfPossible = true}) async {
    final privateKey = await _secureStorage.getValue(key: secureStorageKey);
    if (privateKey.isEmpty) {
      _sessionUsecase.setSession(const Unauth());
      return _sessionUsecase.currentSession;
    }

    final isValid = validatePrivateKey(privateKey) == null;
    if (!isValid) {
      _sessionUsecase.setSession(const Unauth());
      return _sessionUsecase.currentSession;
    }

    final userKeys = _keyToolRepository.getUserKeysWithPrivateKey(
      privateKey: privateKey,
    );
    // Migration: installs that stored a single key before multi-account
    // support have no entry in the accounts list yet.
    await _persistAccount(userKeys);

    final current = _sessionUsecase.currentSession;
    final alreadyOptedOut =
        current is Auth &&
        current.pubkey == userKeys.publicKey &&
        !current.authologinIfPossible;

    _sessionUsecase.setSession(
      Auth(
        userKeys,
        authologinIfPossible: authologinIfPossible && !alreadyOptedOut,
      ),
    );

    return _sessionUsecase.currentSession;
  }

  /// Removes the active account. When other accounts remain, activates the
  /// first of them (locked, PIN required); otherwise ends with [Unauth].
  ///
  /// [authologinIfPossible] controls that fallback account, not the removed
  /// one: an explicit logout (e.g. the "Log out" button, as opposed to just
  /// backgrounding the app) should pass false, so a no-PIN fallback account
  /// stays locked instead of silently auto-unlocking right back in.
  Future<void> logout({bool authologinIfPossible = true}) async {
    final pubkey = _sessionUsecase.currentSession.pubkey;
    if (pubkey.isNotEmpty) {
      await _secureStorage.deleteValue(key: accountStorageKey(pubkey));
      await _accountsRepo.removeAccount(pubkey);
    }

    await _secureStorage.setValue(key: secureStorageKey, value: '');

    final remaining = _accountsRepo.getAccounts();
    if (remaining.isNotEmpty) {
      _sessionUsecase.setSession(const Unauth());
      await switchAccount(
        pubkey: remaining.first,
        authologinIfPossible: authologinIfPossible,
      );
      return;
    }

    _sessionUsecase.setSession(const Unauth());
    _relaysListRepo.clear();
  }

  Future<void> _persistAccount(UserKeys userKeys) async {
    await _secureStorage.setValue(
      key: secureStorageKey,
      value: userKeys.privateKey,
    );
    await _secureStorage.setValue(
      key: accountStorageKey(userKeys.publicKey),
      value: userKeys.privateKey,
    );
    await _accountsRepo.addAccount(userKeys.publicKey);
  }

  KeysError? validatePrivateKey(String? privateKey) {
    try {
      _keyToolRepository.getUserKeysWithPrivateKey(privateKey: privateKey);
    } on KeysError catch (e) {
      return e;
    }

    return null;
  }

  String generateNsecKey() {
    return _keyToolRepository.generateNsecKey();
  }
}
