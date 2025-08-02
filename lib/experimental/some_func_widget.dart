import 'dart:developer';
import 'dart:typed_data';

import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/services/key_tool/nip04_encryptor.dart';

import 'aes_cbc_repo.dart';

class SomeFuncWidget extends StatefulWidget {
  const SomeFuncWidget({super.key});

  @override
  State<SomeFuncWidget> createState() => _SomeFuncWidgetState();
}

class _SomeFuncWidgetState extends State<SomeFuncWidget> {
  late final AesCbcRepo _impl = DiStorage.shared.resolve<AesCbcRepo>();

  late final _nip04Decryptor = Nip04Decryptor(wasmAesCbc: _impl);

  String text = 'loading...';

  String textNip04 = 'loading nip 04 ...';

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    await _impl.init();
    setState(() {
      final res = _impl.someFunction(2.0);
      text = 'Result: ${res.toString()}';
    });

    try {
      final result = _performNip04();

      setState(() {
        textNip04 = result;
      });
    } catch (e) {
      log(
        'decrypted err: $e',
        name: 'WASM',
      );
    }
  }

  String _performNip04() {
    const privateKey =
        '49b3084ebe2d6a1c1c9f68be41c89593c7a1d0a80e23f259df341bfa8e5b5bd8';
    const publicKey =
        '5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee';
    const src =
        r'pgUGzRVXAtn/2w6+D1kmeVzidjdpkRcjLY0z102fmvyXlebBGDx1FS63vyXUMujyIehN95ZVwJ9nl3V5I5VloKG86VdnWEMXbVgHFBFy/yNF+XJEECa2Kuq9b9IkmBvod3fD+fP21memR+rQGffPE2KJknGZ7CsuHMw+PHGz1nA=?iv=jxRfP+eOv/0kpl+QUMmWjw==';

    // final encrypted = _nip04ServiceVariant.decryptNip04(
    //   content: src,
    //   peerPubkey: publicKey,
    //   privateKey: privateKey,
    // );

    final decrypted = _nip04Decryptor.decryptNip04(
      content: src,
      peerPubkey: publicKey,
      privateKey: privateKey,
    );

    log('decrypted: $decrypted', name: 'WASM');

    return decrypted;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Sizes.indent2x),
      child: Column(
        spacing: Sizes.indent2x,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.deepOrange,
            ),
          ),
          Text(
            textNip04,
            style: const TextStyle(
              color: Colors.deepOrange,
            ),
          ),
          // Text(
          //   textNip04Variant,
          //   style: const TextStyle(
          //     color: Colors.deepOrange,
          //   ),
          // ),
        ],
      ),
    );
  }
}

Uint8List removePkcs7Padding(Uint8List data) {
  if (data.isEmpty) return data;

  final paddingLength = data.last;
  if (paddingLength > data.length || paddingLength == 0) {
    return data; // Нет валидного padding
  }

  // Проверяем, что все padding байты одинаковые
  for (int i = data.length - paddingLength; i < data.length; i++) {
    if (data[i] != paddingLength) {
      return data; // Неправильный padding
    }
  }

  return data.sublist(0, data.length - paddingLength);
}
