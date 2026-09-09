import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr_notes/auth/data/login_items/login_item_crypto_usecase_impl.dart';
import 'package:nostr_notes/auth/data/mappers/login_item_mapper.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/domain/model/pin_kdf.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';

const _keys = UserKeys(
  privateKey:
      '49b3084ebe2d6a1c1c9f68be41c89593c7a1d0a80e23f259df341bfa8e5b5bd8',
  publicKey: '5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee',
);

void main() {
  group('LoginItemCryptoUsecaseImpl', () {
    late SessionUsecase sessionUsecase;
    late LoginItemCryptoUsecaseImpl sut;

    setUp(() async {
      sessionUsecase = SessionUsecase();
      final cryptoService = CryptoService.create();
      await cryptoService.init();
      sut = LoginItemCryptoUsecaseImpl(
        cryptoService: cryptoService,
        sessionUsecase: sessionUsecase,
        extraDerivation: ExtraDerivation(
          cryptoService: cryptoService,
          sessionUsecase: sessionUsecase,
        ),
      );
    });

    tearDown(() => sessionUsecase.dispose());

    void unlockWith(String pin) =>
        sessionUsecase.setSession(Unlocked(keys: _keys, pin: pin));

    LoginItem itemWith(String password) => LoginItem(
      eventId: '',
      dTag: 'dTag',
      title: 'example.com',
      username: 'alex',
      password: password,
      websiteUrl: 'https://example.com',
      notes: '',
      image: '',
      totpSecret: null,
      revision: 0,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    test('an item saved with no PIN still opens once a PIN is set', () async {
      unlockWith('');
      final encrypted = await sut.encrypt(itemWith('secret'));

      expect(
        encrypted.kdf,
        PinKdf.none,
        reason: 'the vault entry has to record that no PIN protects it',
      );

      unlockWith('1234');

      expect((await sut.decrypt(encrypted)).password, 'secret');
    });

    test('an item saved with a PIN does not open without it', () async {
      unlockWith('1234');
      final encrypted = await sut.encrypt(itemWith('secret'));

      expect(encrypted.kdf, PinKdf.current);

      unlockWith('');

      await expectLater(sut.decrypt(encrypted), throwsA(anything));
    });

    test('the KDF survives the trip through the event tags', () async {
      unlockWith('');
      final encrypted = await sut.encrypt(itemWith('secret'));

      final event = NostrEvent(
        kind: NostrKind.loginItem,
        id: 'id',
        pubkey: 'pubkey',
        createdAt: 1,
        tags: LoginItemMapper.toTags(encrypted),
        content: encrypted.encryptedPayload,
        sig: 'sig',
      );

      expect(LoginItemMapper.fromNostrEvent(event)!.kdf, PinKdf.none);
    });

    test('an event with no KDF tag predates the tag, not the PIN', () async {
      const event = NostrEvent(
        kind: NostrKind.loginItem,
        id: 'id',
        pubkey: 'pubkey',
        createdAt: 1,
        tags: [
          ['d', 'dTag'],
        ],
        content: 'ciphertext',
        sig: 'sig',
      );

      expect(
        LoginItemMapper.fromNostrEvent(event)!.kdf,
        PinKdf.current,
        reason:
            'login items never shipped a legacy derivation — an untagged one '
            'comes from the build that simply did not write the tag yet, and '
            'that build always used the current KDF',
      );
    });
  });
}
