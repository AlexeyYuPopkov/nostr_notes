import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:common/tools/app_worker/app_worker.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:cryptography/cryptography.dart';
import 'package:nostr_notes/auth/domain/model/pin_kdf.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';

// TODO: create interface. Move impl to data layer.
final class NoteCryptoUseCase {
  final CryptoService _cryptoService;
  final SessionUsecase _sessionUsecase;
  final ExtraDerivation _extraDerivation;

  final nip44Expando = Expando<Map<PinKdf, Uint8List>>(
    'NoteCryptoUseCase.nip44Cache',
  );

  NoteCryptoUseCase({
    required CryptoService cryptoService,
    required SessionUsecase sessionUsecase,
    required ExtraDerivation extraDerivation,
    bool useCache = true,
  }) : _cryptoService = cryptoService,
       _sessionUsecase = sessionUsecase,
       _extraDerivation = extraDerivation;

  Future<Note> encryptNote(Note note) async {
    const kdf = PinKdf.current;
    final pin = _getPin();

    final privateKey = _getPrivateKey();
    final peerPubkey = _getPeerPubkey();

    final session = _sessionUsecase.currentSession;

    final extraDerivation = _extraDerivation.execute(pin, kdf: kdf);

    final conversationKey = await _conversationKey(
      session: session,
      privateKey: privateKey,
      peerPubkey: peerPubkey,
      extraDerivation: extraDerivation,
      kdf: kdf,
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
      final joinedLabels = BaseLabel.joinLabels(note.labels.whereType<Label>());

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
      kdf: kdf,
    );
  }

  Future<Note> decryptNote(Note note) async {
    final privateKey = _getPrivateKey();
    final peerPubkey = _getPeerPubkey();

    final session = _sessionUsecase.currentSession;
    final pin = _getPin();

    final kdf = note.kdf;
    final extraDerivation = _extraDerivation.execute(pin, kdf: kdf);
    final stopwatch = Stopwatch()..start();
    final conversationKey = await _conversationKey(
      session: session,
      privateKey: privateKey,
      peerPubkey: peerPubkey,
      extraDerivation: extraDerivation,
      kdf: kdf,
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

      final decryptedLabelsList = BaseLabel.fromJoinedText(decryptedLabelsJson);
      labels.addAll(decryptedLabelsList);
    }

    log(
      'Note decryption took: ${stopwatch.elapsedMilliseconds} ms',
      name: 'Crypto',
    );

    return note.copyWith(
      content: decryptedContent,
      summary: decryptedSummary,
      labels: labels,
      clearError: true,
    );
  }

  Future<Note> decryptSummary(Note note) async {
    final privateKey = _getPrivateKey();
    final peerPubkey = _getPeerPubkey();

    final pin = _getPin();
    final session = _sessionUsecase.currentSession;

    final kdf = note.kdf;
    final extraDerivation = _extraDerivation.execute(pin, kdf: kdf);
    final stopwatch = Stopwatch()..start();
    final conversationKey = await _conversationKey(
      session: session,
      privateKey: privateKey,
      peerPubkey: peerPubkey,
      extraDerivation: extraDerivation,
      kdf: kdf,
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

  Future<Uint8List> _conversationKey({
    required Session session,
    required String privateKey,
    required String peerPubkey,
    required Future<Uint8List> Function(Uint8List)? extraDerivation,
    required PinKdf kdf,
  }) async {
    final cached = (nip44Expando[session] ??= {})[kdf];
    if (cached != null) {
      return cached;
    }

    final derived = await _cryptoService.deriveKeysAsync(
      senderPrivateKey: privateKey,
      recipientPublicKey: peerPubkey,
      extraDerivation: extraDerivation,
    );

    return (nip44Expando[session] ??= {})[kdf] = derived;
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

  /// Keyed by session, then by KDF: one unlock can touch both legacy notes
  /// and PBKDF2 ones, and each needs its own derived key. Entries die with
  /// the session object, so a logout drops them.
  final _expando = Expando<Map<PinKdf, Uint8List>>(
    'ExtraDerivation.passwordToKeyCache',
  );

  ExtraDerivation({
    required CryptoService cryptoService,
    required SessionUsecase sessionUsecase,
  }) : _cryptoService = cryptoService,
       _sessionUsecase = sessionUsecase;

  Future<Uint8List> Function(Uint8List)? execute(
    String? password, {
    PinKdf kdf = PinKdf.current,
  }) {
    if (password == null || password.isEmpty) {
      return null;
    }
    return (Uint8List input) => _extraDerivation(password, input, kdf);
  }

  /// [baseKey] is the conversation key the account's own keys already
  /// produced — despite the parameter name upstream, it is not a pubkey.
  Future<Uint8List> _extraDerivation(
    String password,
    Uint8List baseKey,
    PinKdf kdf,
  ) async {
    final session = _sessionUsecase.currentSession;
    final cached = (_expando[session] ??= {})[kdf];
    if (cached != null) {
      return cached;
    }

    final pinKey = await _passwordToKey(password, baseKey, kdf);
    final derived = await _cryptoService.spec256k1Async(
      senderPrivateKey: pinKey,
      recipientPublicKey: baseKey,
    );

    return (_expando[session] ??= {})[kdf] = derived;
  }

  Future<Uint8List> _passwordToKey(
    String pin,
    Uint8List baseKey,
    PinKdf kdf,
  ) async {
    switch (kdf) {
      case PinKdf.legacySha256:
        return Uint8List.fromList(sha256.convert(utf8.encode(pin)).bytes);
      case PinKdf.pbkdf2:
        return AppWorker.instance.compute(
          params: (pin: pin, salt: _salt(baseKey)),
          callback: stretchPin,
        );
    }
  }

  /// The account's own key material is the only per-account value available
  /// here, and a PIN is never persisted, so there is nowhere to keep a random
  /// salt. Deriving it from [baseKey] keeps the salt account-specific without
  /// storing anything.
  static Uint8List _salt(Uint8List baseKey) {
    final input = [...utf8.encode(PinKdf.saltInfo), ...baseKey];
    return Uint8List.fromList(sha256.convert(input).bytes);
  }
}

/// Top-level so it can cross an isolate boundary. Blocks its isolate for
/// [PinKdf.pbkdf2Iterations] rounds — never call it on the UI isolate.
Future<Uint8List> stretchPin(({String pin, Uint8List salt}) params) async {
  final key = await Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: PinKdf.pbkdf2Iterations,
    bits: 256,
  ).deriveKeyFromPassword(password: params.pin, nonce: params.salt);

  return Uint8List.fromList(await key.extractBytes());
}
