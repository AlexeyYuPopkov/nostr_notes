import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';

final class NoteCryptoUseCase {
  final CryptoService _cryptoService;
  final SessionUsecase _sessionUsecase;
  final ExtraDerivation _extraDerivation;

  final nip44Expando = Expando<Uint8List>('NoteCryptoUseCase.nip44Cache');

  NoteCryptoUseCase({
    required CryptoService cryptoService,
    required SessionUsecase sessionUsecase,
    required ExtraDerivation extraDerivation,
    bool useCache = true,
  }) : _cryptoService = cryptoService,
       _sessionUsecase = sessionUsecase,
       _extraDerivation = extraDerivation;

  Future<Note> encryptNote(Note note) async {
    final pin = _getPin();

    final privateKey = _getPrivateKey();
    final peerPubkey = _getPeerPubkey();

    final session = _sessionUsecase.currentSession;

    final extraDerivation = _extraDerivation.execute(pin);

    final conversationKey = nip44Expando[session] ??= await _cryptoService
        .deriveKeysAsync(
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

    final labels = <EncryptedLabel>[];

    if (note.labels.isNotEmpty) {
      final joinedLabels = jsonEncode(
        note.labels.map((label) => label.textValue).toList(),
      );

      final encryptedLabels = await _cryptoService.encryptNip44(
        plaintext: joinedLabels,
        conversationKey: conversationKey,
      );

      final encryptedLabel = EncryptedLabel(textValue: encryptedLabels);

      labels.add(encryptedLabel);
    }

    return note.copyWith(
      content: encryptedContent,
      summary: encryptedSummary,
      labels: labels,
    );
  }

  Future<Note> decryptNote(Note note) async {
    final privateKey = _getPrivateKey();
    final peerPubkey = _getPeerPubkey();

    final session = _sessionUsecase.currentSession;
    final pin = _getPin();

    final extraDerivation = _extraDerivation.execute(pin);
    final stopwatch = Stopwatch()..start();
    final conversationKey = nip44Expando[session] ??= await _cryptoService
        .deriveKeysAsync(
          senderPrivateKey: privateKey,
          recipientPublicKey: peerPubkey,
          extraDerivation: extraDerivation,
        );

    log(
      'DeriveKeys (note) took: ${stopwatch.elapsedMilliseconds} ms',
      name: 'Crypto',
    );

    final decryptedContent = await _cryptoService.decryptNip44(
      payload: note.content,
      conversationKey: conversationKey,
    );

    final decryptedSummary = await _cryptoService.decryptNip44(
      payload: note.summary,
      conversationKey: conversationKey,
    );

    final labels = <BaseLabel>[];

    if (note.labels.isNotEmpty) {
      final encryptedLabel = note.labels.first;
      final decryptedLabelsJson = await _cryptoService.decryptNip44(
        payload: encryptedLabel.textValue,
        conversationKey: conversationKey,
      );

      final decryptedLabelsList =
          jsonDecode(decryptedLabelsJson) as List<dynamic>;

      for (final labelText in decryptedLabelsList) {
        labels.add(Label.from(labelText as String));
      }
    }

    log(
      'Note decryption took: ${stopwatch.elapsedMilliseconds} ms',
      name: 'Crypto',
    );

    return note.copyWith(
      content: decryptedContent,
      summary: decryptedSummary,
      labels: labels,
    );
  }

  Future<Note> decryptSummary(Note note) async {
    final privateKey = _getPrivateKey();
    final peerPubkey = _getPeerPubkey();

    final pin = _getPin();
    final session = _sessionUsecase.currentSession;

    final extraDerivation = _extraDerivation.execute(pin);
    final stopwatch = Stopwatch()..start();
    final conversationKey = nip44Expando[session] ??= await _cryptoService
        .deriveKeysAsync(
          senderPrivateKey: privateKey,
          recipientPublicKey: peerPubkey,
          extraDerivation: extraDerivation,
        );

    log(
      'DeriveKeys (summary) took: ${stopwatch.elapsedMilliseconds} ms',
      name: 'Crypto',
    );

    try {
      final decryptedSummary = await _cryptoService.decryptNip44(
        payload: note.summary,
        conversationKey: conversationKey,
      );

      log(
        'Summary decryption took: ${stopwatch.elapsedMilliseconds} ms',
        name: 'Crypto',
      );

      return note.copyWith(summary: decryptedSummary);
    } catch (e) {
      return note.copyWith(summary: 'Cannot decrypt..', error: e);
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

class ExtraDerivation {
  final CryptoService _cryptoService;
  final SessionUsecase _sessionUsecase;

  final _expando = Expando<Uint8List>('ExtraDerivation.passwordToKeyCache');

  ExtraDerivation({
    required CryptoService cryptoService,
    required SessionUsecase sessionUsecase,
  }) : _cryptoService = cryptoService,
       _sessionUsecase = sessionUsecase;

  Future<Uint8List> Function(Uint8List)? execute(String? password) {
    if (password == null || password.isEmpty) {
      return null;
    }
    return (Uint8List input) => _extraDerivation(password, input);
  }

  Future<Uint8List> _extraDerivation(
    String password,
    Uint8List peerPubkey,
  ) async {
    final pinKey = _passwordToKey(password);

    final session = _sessionUsecase.currentSession;

    final conversationKey = _expando[session] ??= await _cryptoService
        .spec256k1Async(
          senderPrivateKey: pinKey,
          recipientPublicKey: peerPubkey,
        );

    log(
      'Modifyed secret ${conversationKey.join(', ')}',
      name: 'ExtraDerivation',
    );
    // 32 байта
    return conversationKey;
  }

  Uint8List _passwordToKey(String pin) {
    // RU: дополнить до 32 байта
    // EN: pad to 32 bytes
    final hash = sha256.convert(utf8.encode(pin));
    return Uint8List.fromList(hash.bytes);
  }
}
