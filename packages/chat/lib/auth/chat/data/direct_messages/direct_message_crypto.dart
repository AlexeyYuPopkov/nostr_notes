import 'dart:developer';
import 'dart:typed_data';

import 'package:chat/auth/chat/domain/models/chat_message.dart';
import 'package:common/tools/app_worker/app_worker.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/nostr_event_verification.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr/nip44/derive_keys.dart';
import 'package:nostr/nip44/nip44.dart';

import 'direct_message_tags.dart';

/// NIP-44 for direct messages. Verification and decryption run on [AppWorker]
/// in chunks and are remembered by event id, so a store update handles only
/// new events.
final class DirectMessageCrypto {
  static const _chunkSize = 50;

  final AppWorker _worker;
  final _decrypted = <String, ChatMessage?>{};

  DirectMessageCrypto({AppWorker? worker})
    : _worker = worker ?? AppWorker.instance;

  Future<String> encrypt({
    required UserKeys keys,
    required String peerPubkey,
    required String text,
  }) {
    return const Nip44().encryptMessage(
      plaintext: text,
      conversationKey: _ConversationKeys.of(
        privateKey: keys.privateKey,
        myPubkey: keys.publicKey,
        peerPubkey: peerPubkey,
      ),
    );
  }

  /// Messages of [events] that are authentic and decrypt; the rest are logged
  /// and left out.
  Future<List<ChatMessage>> decrypt({
    required UserKeys keys,
    required Iterable<NostrEvent> events,
  }) async {
    final unknown = events.where((e) => !_decrypted.containsKey(e.id)).toList();

    for (var start = 0; start < unknown.length; start += _chunkSize) {
      final chunk = unknown.sublist(
        start,
        (start + _chunkSize).clamp(0, unknown.length),
      );
      final messages = await _worker.compute(
        params: _DecryptParams(keys: keys, events: chunk),
        callback: _decryptChunk,
      );
      for (final (index, event) in chunk.indexed) {
        _decrypted[event.id] = messages[index];
      }
    }

    return [for (final event in events) ?_decrypted[event.id]];
  }

  static Future<List<ChatMessage?>> _decryptChunk(_DecryptParams params) async {
    final keys = params.keys;
    final result = <ChatMessage?>[];

    for (final event in params.events) {
      if (!event.isAuthentic) {
        log('Dropped forged ${event.id}', name: 'DirectMessageCrypto');
        result.add(null);
        continue;
      }
      final peer = event.pubkey == keys.publicKey
          ? DirectMessageTags.peerOf(event)
          : event.pubkey;
      if (peer == null || peer.isEmpty) {
        result.add(null);
        continue;
      }

      try {
        final text = await const Nip44().decryptMessage(
          payload: event.content,
          conversationKey: _ConversationKeys.of(
            privateKey: keys.privateKey,
            myPubkey: keys.publicKey,
            peerPubkey: peer,
          ),
        );
        result.add(DirectMessageTags.toMessage(event, text));
      } catch (e) {
        log('Cannot decrypt ${event.id}: $e', name: 'DirectMessageCrypto');
        result.add(null);
      }
    }

    return result;
  }
}

final class _DecryptParams {
  final UserKeys keys;
  final List<NostrEvent> events;

  const _DecryptParams({required this.keys, required this.events});
}

/// The ECDH secret per conversation. Static so the worker isolate, which
/// lives for the whole session, keeps it between chunks.
abstract final class _ConversationKeys {
  static final _cache = <String, Uint8List>{};

  static Uint8List of({
    required String privateKey,
    required String myPubkey,
    required String peerPubkey,
  }) {
    return _cache.putIfAbsent(
      '$myPubkey:$peerPubkey',
      () => DeriveKeys.spec256k1(privateKey, peerPubkey),
    );
  }
}
