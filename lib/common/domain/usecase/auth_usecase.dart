import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/repository/key_tool_repository.dart';
import 'package:nostr_notes/common/domain/repository/secure_storage.dart';

import 'session_usecase.dart';

final class AuthUsecase {
  static const String secureStorageKey = 'NostrNotes.Nsec';

  final SecureStorage _secureStorage;
  final SessionUsecase _sessionUsecase;
  final KeyToolRepository _keyToolRepository;

  AuthUsecase({
    required SecureStorage secureStorage,
    required SessionUsecase sessionUsecase,
    required KeyToolRepository keyToolRepository,
  })  : _secureStorage = secureStorage,
        _sessionUsecase = sessionUsecase,
        _keyToolRepository = keyToolRepository;

  Stream<Session> get session => _sessionUsecase.sessionStream;

  Future<void> execute({required String nsec}) async {
    final nsecTrimmed = nsec.trim();
    final userKeys = _keyToolRepository.getUserKeys(nsec: nsecTrimmed);
    _secureStorage.setValue(key: secureStorageKey, value: userKeys.privateKey);

    final currentSession = _sessionUsecase.currentSession;
    switch (currentSession) {
      case Unauth():
        _sessionUsecase.setSession(
          currentSession.toAuth(keys: userKeys),
        );
        break;
      case Auth():
      case Unlocked():
        assert(
          false,
          'Session should not be Auth or Unlocked when setting a nsec',
        );
    }
  }

  NsecError? validate(String? nsec) {
    try {
      _keyToolRepository.getUserKeys(nsec: nsec);
    } on NsecError catch (e) {
      return e;
    }

    return null;
  }
}
