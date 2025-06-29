import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/repo/crypto_algorithm_type.dart';
import 'package:nostr_notes/auth/domain/repo/crypto_repo.dart';
import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';

final class NoteCryptoUseCase {
  final CryptoRepo _cryptoRepo;
  final SessionUsecase _sessionUsecase;

  final nip44Expando = Expando<CryptoAlgorithmType>(
    'Nip44CryptoAlgorithmType',
  );

  NoteCryptoUseCase({
    required CryptoRepo cryptoRepo,
    required SessionUsecase sessionUsecase,
  })  : _cryptoRepo = cryptoRepo,
        _sessionUsecase = sessionUsecase;

  Future<Note> encryptNote(Note note) async {
    final pin = _getPin();

    final privateKey = _getPrivateKey();
    final peerPubkey = _getPeerPubkey();

    final session = _sessionUsecase.currentSession;

    final cacheNip44 = nip44Expando[session] ??= await _cryptoRepo.createCache(
      algorithmType: CryptoAlgorithmType.nip44(
        privateKey: privateKey,
        peerPubkey: peerPubkey,
        additionalPassword: pin,
      ),
    );

    final encryptedContent = await _cryptoRepo.encryptMessage(
      text: note.content,
      algorithmType: cacheNip44,
    );

    final encryptedSummary = await _cryptoRepo.encryptMessage(
      text: note.summary,
      algorithmType: cacheNip44,
    );

    return note.copyWith(
      content: encryptedContent,
      summary: encryptedSummary,
    );
  }

  Future<Note> encryptSummary(Note note) async {
    final pin = _getPin();

    final privateKey = _getPrivateKey();
    final peerPubkey = _getPeerPubkey();

    final session = _sessionUsecase.currentSession;

    final cacheNip44 = nip44Expando[session] ??= await _cryptoRepo.createCache(
      algorithmType: CryptoAlgorithmType.nip44(
        privateKey: privateKey,
        peerPubkey: peerPubkey,
        additionalPassword: pin,
      ),
    );

    final encryptedSummary = await _cryptoRepo.encryptMessage(
      text: note.summary,
      algorithmType: cacheNip44,
    );

    return note.copyWith(summary: encryptedSummary);
  }

  Future<Note> decryptNote(Note note) async {
    final privateKey = _getPrivateKey();
    final peerPubkey = _getPeerPubkey();

    final session = _sessionUsecase.currentSession;

    final pin = _getPin();

    final cacheNip44 = nip44Expando[session] ??= await _cryptoRepo.createCache(
      algorithmType: CryptoAlgorithmType.nip44(
        privateKey: privateKey,
        peerPubkey: peerPubkey,
        additionalPassword: pin,
      ),
    );

    final decryptedContent = await _cryptoRepo.decryptMessage(
      text: note.content,
      algorithmType: cacheNip44,
    );

    final decryptedSummary = await _cryptoRepo.decryptMessage(
      text: note.summary,
      algorithmType: cacheNip44,
    );

    return note.copyWith(
      content: decryptedContent,
      summary: decryptedSummary,
    );
  }

  Future<Note> decryptSummary(Note note) async {
    final privateKey = _getPrivateKey();
    final peerPubkey = _getPeerPubkey();

    final pin = _getPin();
    final session = _sessionUsecase.currentSession;

    final cacheNip44 = nip44Expando[session] ??= await _cryptoRepo.createCache(
      algorithmType: CryptoAlgorithmType.nip44(
        privateKey: privateKey,
        peerPubkey: peerPubkey,
        additionalPassword: pin,
      ),
    );

    final decryptedSummary = await _cryptoRepo.decryptMessage(
      text: note.summary,
      algorithmType: cacheNip44,
    );

    return note.copyWith(summary: decryptedSummary);
  }

  String _getPin() {
    final session = _sessionUsecase.currentSession;
    switch (session) {
      case Unauth():
        throw const AppError.notAuthenticated();
      case Auth():
        throw const AppError.notUnlocked();
      case Unlocked():
        return session.pin;
    }
  }

  String _getPrivateKey() {
    final session = _sessionUsecase.currentSession;
    switch (session) {
      case Unauth():
        throw const AppError.notAuthenticated();
      case Auth():
        return session.keys.privateKey;
      case Unlocked():
        return session.keys.privateKey;
    }
  }

  String _getPeerPubkey() {
    final session = _sessionUsecase.currentSession;
    switch (session) {
      case Unauth():
        throw const AppError.notAuthenticated();
      case Auth():
        return session.keys.publicKey;
      case Unlocked():
        return session.keys.publicKey;
    }
  }
}
