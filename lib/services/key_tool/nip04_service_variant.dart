import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:kepler/kepler.dart';
import 'package:nostr_notes/experimental/aes_cbc_repo.dart';

import 'package:pointycastle/export.dart';

import 'dart:developer' as dev;

class Nip04ServiceVariant {
  final AesCbcRepo wasmAesCbc;

  Nip04ServiceVariant({required this.wasmAesCbc});

  String encryptNip04({
    required String content,
    required String peerPubkey,
    required String privateKey,
  }) {
    return _encrypt(privateKey, '02$peerPubkey', content);
  }

  // String decryptNip04({
  //   required String content,
  //   required String peerPubkey,
  //   required String privateKey,
  // }) =>
  //     _decryptContent1WithPrivateKey(
  //       content: content,
  //       peerPubkey: peerPubkey,
  //       privateKey: privateKey,
  //     );

  String _encrypt(String privateKey, String publicKey, String plainText) {
    final uintInputText = const Utf8Encoder().convert(plainText);
    final encryptedString = _encryptRaw(
      privateKey,
      publicKey,
      uintInputText,
    );
    return encryptedString;
  }

  String _encryptRaw(
    String privateKey,
    String publicKey,
    Uint8List uintInputText,
  ) {
    final secretIV = Kepler.byteSecret(privateKey, publicKey);
    final key = Uint8List.fromList(secretIV[0]);

    // generate iv  https://stackoverflow.com/questions/63630661/aes-engine-not-initialised-with-pointycastle-securerandom
    final fr = FortunaRandom();
    final sGen = math.Random.secure();
    fr.seed(
      KeyParameter(
        Uint8List.fromList(List.generate(32, (_) => sGen.nextInt(255))),
      ),
    );
    final iv = fr.nextBytes(16);

    final CipherParameters params = PaddedBlockCipherParameters(
      ParametersWithIV(KeyParameter(key), iv),
      null,
    );

    final cipherImpl =
        PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESEngine()));

    cipherImpl.init(
      true, // means to encrypt
      params
          as PaddedBlockCipherParameters<CipherParameters?, CipherParameters?>,
    );

    // allocate space
    final outputEncodedText = Uint8List(uintInputText.length + 16);

    var offset = 0;
    while (offset < uintInputText.length - 16) {
      offset += cipherImpl.processBlock(
        uintInputText,
        offset,
        outputEncodedText,
        offset,
      );
    }

    //add padding
    offset +=
        cipherImpl.doFinal(uintInputText, offset, outputEncodedText, offset);
    final finalEncodedText = outputEncodedText.sublist(0, offset);

    final stringIv = base64.encode(iv);
    var outputPlainText = base64.encode(finalEncodedText);
    outputPlainText = '$outputPlainText?iv=$stringIv';
    return outputPlainText;
  }

  String decryptNip04({
    required String content,
    required String peerPubkey,
    required String privateKey,
  }) {
    final ivIndex = content.indexOf('?iv=');
    if (ivIndex <= 0) {
      if (kDebugMode) {
        print('Invalid content for dm, could not get ivIndex: $content');
      }
      return '';
    }
    final iv = content.substring(ivIndex + '?iv='.length, content.length);
    final encString = content.substring(0, ivIndex);
    final result = _decrypt(privateKey, '02$peerPubkey', encString, iv);

    log(
      'result: $result',
      name: 'WASM',
    );

    return result;
  }

// pointy castle source https://github.com/PointyCastle/pointycastle/blob/master/tutorials/aes-cbc.md
// https://github.com/bcgit/pc-dart/blob/master/tutorials/aes-cbc.md
// 3 https://github.com/Dhuliang/flutter-bsv/blob/42a2d92ec6bb9ee3231878ffe684e1b7940c7d49/lib/src/aescbc.dart

  /// Decrypt data using self private key
  String _decrypt(
    String privateString,
    String publicString,
    String b64encoded, [
    String b64IV = '',
  ]) {
    final deData = base64.decode(b64encoded);
    final rawData = _decryptRaw(privateString, publicString, deData, b64IV);
    // final str = utf8.decode(rawData, allowMalformed: true);
    // final result = const Utf8Decoder().convert(rawData);
    return const Utf8Decoder().convert(rawData);
  }

  Uint8List _decryptRaw(
    String privateString,
    String publicString,
    Uint8List cipherText, [
    String b64IV = '',
  ]) {
    final byteSecret = Kepler.byteSecret(privateString, publicString);
    final secretIV = byteSecret;
    final key = Uint8List.fromList(secretIV[0]);
    final iv = b64IV.length > 6
        ? base64.decode(b64IV)
        : Uint8List.fromList(secretIV[1]);

    final CipherParameters params = PaddedBlockCipherParameters(
      ParametersWithIV(KeyParameter(key), iv),
      null,
    );

    final cipherImpl =
        PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESEngine()));

    cipherImpl.init(
      false,
      params
          as PaddedBlockCipherParameters<CipherParameters?, CipherParameters?>,
    );
    final finalPlainText = Uint8List(cipherText.length); // allocate space

    var offset = 0;
    while (offset < cipherText.length - 16) {
      offset +=
          cipherImpl.processBlock(cipherText, offset, finalPlainText, offset);
    }
    //remove padding
    offset += cipherImpl.doFinal(cipherText, offset, finalPlainText, offset);
    final pointyCastleResult = finalPlainText.sublist(0, offset);

    if (kIsWeb) {
      // dev.log('PointyCastle result: ${utf8.decode(pointyCastleResult)}',
      //     name: 'Debug');

      // ignore: unused_local_variable
      final bytes = wasmAesCbc.decryptAes256Cbc(
        ciphertext: cipherText,
        key: key,
        iv: iv,
      );

      // dev.log('WASM output length: ${bytes.length}', name: 'Debug');
      // dev.log(
      //     'WASM first 10 bytes: ${bytes.take(10).map((b) => b.toRadixString(16)).join(' ')}',
      //     name: 'Debug');
      // dev.log(
      //     'WASM last 10 bytes: ${bytes.skip(bytes.length - 10).map((b) => b.toRadixString(16)).join(' ')}',
      //     name: 'Debug');

      // // Проверьте, есть ли в WASM выводе валидные UTF-8 символы
      // try {
      //   final testString = utf8.decode(bytes.take(20).toList());
      //   dev.log('WASM first 20 bytes as UTF-8: "$testString"', name: 'Debug');
      // } catch (e) {
      //   dev.log('WASM first 20 bytes not valid UTF-8', name: 'Debug');
      // }

      return pointyCastleResult;
    }

    return pointyCastleResult;
  }
}

// ignore: unused_element
Uint8List _removePkcs7Padding(Uint8List data) {
  if (data.isEmpty) {
    return data;
  }

  final paddingLength = data.last;

  // Валидация padding
  if (paddingLength > 16 || paddingLength == 0 || paddingLength > data.length) {
    dev.log('Invalid padding length: $paddingLength', name: 'Wasm');
    return data; // Возвращаем исходные данные, если padding невалидный
  }

  // Проверяем, что все padding байты одинаковые
  for (int i = data.length - paddingLength; i < data.length; i++) {
    if (data[i] != paddingLength) {
      dev.log('Invalid padding bytes at position $i', name: 'Wasm');
      return data; // Возвращаем исходные данные, если padding неправильный
    }
  }

  final result = data.sublist(0, data.length - paddingLength);
  dev.log('Removed $paddingLength padding bytes', name: 'Wasm');
  return result;
}

// ignore: unused_element
bool _bytesEqual(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
