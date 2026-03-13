import 'package:nostr_notes/auth/domain/repo/relays_list_repo.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/repository/key_tool_repository.dart';
import 'package:nostr_notes/common/domain/repository/secure_storage.dart';

import 'session_usecase.dart';

final class AuthUsecase {
  static const String secureStorageKey = 'NostrNotes.Nsec';

  final SecureStorage _secureStorage;
  final SessionUsecase _sessionUsecase;
  final KeyToolRepository _keyToolRepository;
  final RelaysListRepo _relaysListRepo;

  AuthUsecase({
    required SecureStorage secureStorage,
    required SessionUsecase sessionUsecase,
    required KeyToolRepository keyToolRepository,
    required RelaysListRepo relaysListRepo,
  }) : _secureStorage = secureStorage,
       _sessionUsecase = sessionUsecase,
       _keyToolRepository = keyToolRepository,
       _relaysListRepo = relaysListRepo;

  Stream<Session> get session => _sessionUsecase.sessionStream;
  Session get currentSession => _sessionUsecase.currentSession;

  Future<void> execute({required String nsec}) async {
    final userKeys = _keyToolRepository.getUserKeysWithNsec(nsec: nsec);
    _secureStorage.setValue(key: secureStorageKey, value: userKeys.privateKey);

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

  Future<void> restore() async {
    final privateKey = await _secureStorage.getValue(key: secureStorageKey);
    if (privateKey.isEmpty) {
      _sessionUsecase.setSession(const Unauth());
      return;
    }

    final isValid = validatePrivateKey(privateKey) == null;
    if (!isValid) {
      _sessionUsecase.setSession(const Unauth());
      return;
    }

    final userKeys = _keyToolRepository.getUserKeysWithPrivateKey(
      privateKey: privateKey,
    );
    _sessionUsecase.setSession(Auth(userKeys));
  }

  Future<void> logout() async {
    _secureStorage.setValue(key: secureStorageKey, value: '');
    _sessionUsecase.setSession(const Unauth());
    _relaysListRepo.clear();
  }

  KeysError? validateNsec(String? nsec) {
    try {
      _keyToolRepository.getUserKeysWithNsec(nsec: nsec);
    } on KeysError catch (e) {
      return e;
    }

    return null;
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
