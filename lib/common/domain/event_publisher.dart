import 'package:nostr_notes/core/tools/now.dart';

abstract interface class EventPublisher {
  Future<void> publishNote({
    required String content,
    required String publicKey,
    required String privateKey,
    Now? now,
  });
}
