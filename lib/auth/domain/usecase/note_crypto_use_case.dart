import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/scrypt.dart';

final class NoteCryptoUseCase {
  final CryptoService _cryptoService;
  final SessionUsecase _sessionUsecase;
  final ExtraDerivation _extraDerivation;

  final nip44Expando = Expando<Uint8List>(
    'NoteCryptoUseCase.nip44Cache',
  );

  NoteCryptoUseCase({
    required CryptoService cryptoService,
    required SessionUsecase sessionUsecase,
    ExtraDerivation extraDerivation = const ExtraDerivation(),
    bool useCache = true,
  })  : _cryptoService = cryptoService,
        _sessionUsecase = sessionUsecase,
        _extraDerivation = extraDerivation;

  Future<Note> encryptNote(Note note) async {
    final pin = _getPin();

    final privateKey = _getPrivateKey();
    final peerPubkey = _getPeerPubkey();

    final session = _sessionUsecase.currentSession;

    final extraDerivation = _extraDerivation.execute(pin);

    final conversationKey = nip44Expando[session] ??= _cryptoService.deriveKeys(
      senderPrivateKey: privateKey,
      recipientPublicKey: peerPubkey,
      extraDerivation: extraDerivation,
    );

    final encryptedContent = await _cryptoService.encryptNip44(
      plaintext: note.content,
      conversationKey: conversationKey,
    );

    final encryptedSummary = await _cryptoService.encryptNip44(
      plaintext: note.summary,
      conversationKey: conversationKey,
    );

    return note.copyWith(
      content: encryptedContent,
      summary: encryptedSummary,
    );
  }

  Future<Note> decryptNote(Note note) async {
    final privateKey = _getPrivateKey();
    final peerPubkey = _getPeerPubkey();

    final session = _sessionUsecase.currentSession;
    final pin = _getPin();

    final extraDerivation = _extraDerivation.execute(pin);

    final conversationKey = nip44Expando[session] ??= _cryptoService.deriveKeys(
      senderPrivateKey: privateKey,
      recipientPublicKey: peerPubkey,
      extraDerivation: extraDerivation,
    );

    final decryptedContent = await _cryptoService.decryptNip44(
      payload: note.content,
      conversationKey: conversationKey,
    );

    final decryptedSummary = await _cryptoService.decryptNip44(
      payload: note.summary,
      conversationKey: conversationKey,
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

    final extraDerivation = _extraDerivation.execute(pin);

    final conversationKey = nip44Expando[session] ??= _cryptoService.deriveKeys(
      senderPrivateKey: privateKey,
      recipientPublicKey: peerPubkey,
      extraDerivation: extraDerivation,
    );

    try {
      final decryptedSummary = await _cryptoService.decryptNip44(
        payload: note.summary,
        conversationKey: conversationKey,
      );
      return note.copyWith(summary: decryptedSummary);
    } catch (e) {
      return note.copyWith(summary: 'Cannot decrypt..');
    }
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

final class ExtraDerivation {
  const ExtraDerivation();

  Uint8List Function(Uint8List)? execute(String? password) {
    // return null;
    if (password == null || password.isEmpty) {
      return null;
    }
    return (Uint8List input) => _generateFinalKey(password, input);
  }

  Uint8List _generateFinalKey(
    String password,
    Uint8List conversationSecret,
  ) {
    final passwordKey = _derivePasswordKey(password, conversationSecret);
    final hmac = Hmac(sha256, passwordKey);
    final digest = hmac.convert(conversationSecret);
    return Uint8List.fromList(digest.bytes);
  }

  Uint8List _derivePasswordKey(
    String password,
    Uint8List salt, {
    int keyLength = 32,
  }) {
    final scrypt = Scrypt()
      ..init(ScryptParameters(16384, 8, 1, keyLength, salt));
    return scrypt.process(utf8.encode(password));
  }
}
