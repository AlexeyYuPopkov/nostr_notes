import 'dart:convert';
import 'dart:typed_data';

import 'package:common/domain/error/app_error.dart';
import 'package:nostr_notes/auth/data/models/login_item_payload.dart';
import 'package:nostr_notes/auth/domain/model/encrypted_login_item.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/domain/model/pin_kdf.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/login_item_crypto_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';

/// Uses the same NIP-44 conversation-key derivation as notes (session keys +
/// PIN extra derivation), but over the [LoginItemPayload] JSON as a single
/// blob. Always [PinKdf.current]: unlike notes, login items never shipped,
/// so no ciphertext exists that predates PBKDF2. Kept separate from `NoteCryptoUseCase` so the existing class stays
/// untouched and `Note`-typed.
final class LoginItemCryptoUsecaseImpl implements LoginItemCryptoUsecase {
  final CryptoService _cryptoService;
  final SessionUsecase _sessionUsecase;
  final ExtraDerivation _extraDerivation;

  final _conversationKeyCache = Expando<Uint8List>(
    'LoginItemCryptoUsecaseImpl.nip44Cache',
  );

  LoginItemCryptoUsecaseImpl({
    required CryptoService cryptoService,
    required SessionUsecase sessionUsecase,
    required ExtraDerivation extraDerivation,
  }) : _cryptoService = cryptoService,
       _sessionUsecase = sessionUsecase,
       _extraDerivation = extraDerivation;

  @override
  Future<EncryptedLoginItem> encrypt(LoginItem item) async {
    final payload = LoginItemPayload(
      v: LoginItemPayload.supportedVersion,
      title: item.title,
      username: item.username,
      password: item.password,
      url: item.websiteUrl,
      notes: item.notes,
      updatedAt: item.updatedAt.millisecondsSinceEpoch ~/ 1000,
      image: item.image.isEmpty ? null : item.image,
      totp: item.totpSecret,
      rev: item.revision,
    );

    final encryptedPayload = await _cryptoService.encryptNip44(
      plaintext: jsonEncode(payload.toJson()),
      conversationKey: await _conversationKey(),
    );

    return EncryptedLoginItem(
      eventId: item.eventId,
      dTag: item.dTag,
      encryptedPayload: encryptedPayload,
      createdAt: item.createdAt,
    );
  }

  @override
  Future<LoginItem> decrypt(EncryptedLoginItem item) async {
    final payloadJson = await _cryptoService.decryptNip44(
      payload: item.encryptedPayload,
      conversationKey: await _conversationKey(),
    );

    final payload = LoginItemPayload.fromJson(
      jsonDecode(payloadJson) as Map<String, dynamic>,
    );

    return LoginItem(
      eventId: item.eventId,
      dTag: item.dTag,
      title: payload.title,
      username: payload.username,
      password: payload.password,
      websiteUrl: payload.url,
      notes: payload.notes,
      image: payload.image ?? '',
      totpSecret: payload.totp,
      revision: payload.rev,
      createdAt: item.createdAt,
      updatedAt: payload.updatedAt == null
          ? item.createdAt
          : DateTime.fromMillisecondsSinceEpoch(
              payload.updatedAt! * 1000,
              isUtc: true,
            ),
    );
  }

  Future<Uint8List> _conversationKey() async {
    final session = _sessionUsecase.currentSession;
    final unlocked = switch (session) {
      Unauth() => throw const AppError.notAuthenticated(),
      Auth() => throw const AppError.notUnlocked(),
      final Unlocked s => s,
    };

    final extraDerivation = _extraDerivation.execute(
      unlocked.pin,
      kdf: PinKdf.current,
    );

    return _conversationKeyCache[unlocked] ??= await _cryptoService
        .deriveKeysAsync(
          senderPrivateKey: unlocked.keys.privateKey,
          recipientPublicKey: unlocked.keys.publicKey,
          extraDerivation: extraDerivation,
        );
  }
}
