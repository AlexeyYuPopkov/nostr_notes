import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/common/domain/event_publisher.dart';
import 'package:nostr_notes/core/services/model/tag/tag.dart';
import 'package:nostr_notes/core/services/key_tool/nip04_service.dart';
import 'package:nostr_notes/core/services/nostr_client.dart';
import 'package:nostr_notes/core/services/nostr_event_creator.dart';
import 'package:nostr_notes/core/tools/now.dart';

final class EventPublisherImpl implements EventPublisher {
  final NostrClient nostrClient;

  const EventPublisherImpl({
    required this.nostrClient,
  });

  @override
  Future<void> publishNote({
    required String content,
    required String publicKey,
    required String privateKey,
    Now? now = const Now(),
    Nip04Service? nip04 = const Nip04Service(),
  }) async {
    final createdAt = (now ?? const Now()).now();
    final nip_04 = nip04 ?? const Nip04Service();
    final encryptedMessage = nip_04.encryptNip04(
      content: content,
      peerPubkey: publicKey,
      privateKey: privateKey,
    );

    assert(
      nip_04.decryptNip04(
            content: encryptedMessage,
            peerPubkey: publicKey,
            privateKey: privateKey,
          ) ==
          content,
      'Decrypt message should be equal to original content',
    );

    final List<List<String>> tags = [
      AppConfig.clientTagList(),
      [
        Tag.p.name,
        publicKey,
      ],
    ];

    final event = NostrEventCreator.createEvent(
      kind: 4,
      content: encryptedMessage,
      createdAt: createdAt,
      tags: tags,
      pubkey: publicKey,
      privateKey: privateKey,
    );

    nostrClient.addRelay('wss://testing.gathr.gives/');
    nostrClient.addRelay('wss://relay.damus.io');
    await nostrClient.connect();
    nostrClient.publishEventToAll(event);
  }
}
