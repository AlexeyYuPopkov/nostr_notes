import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/auth/domain/repo/relays_list_repo.dart';
import 'package:nostr_notes/common/domain/event_publisher.dart';
import 'package:nostr_notes/services/model/tag/tag.dart';
import 'package:nostr_notes/services/key_tool/nip04_service.dart';
import 'package:nostr_notes/services/nostr_client.dart';
import 'package:nostr_notes/services/nostr_event_creator.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:uuid/uuid.dart';

final class EventPublisherImpl implements EventPublisher {
  final NostrClient nostrClient;
  final RelaysListRepo relaysListRepo;
  final Nip04Service nip04;

  const EventPublisherImpl({
    required this.nostrClient,
    required this.relaysListRepo,
    this.nip04 = const Nip04Service(),
  });

  @override
  Future<EventPublisherResult> publishNote({
    required String content,
    required String publicKey,
    required String privateKey,
    required String? dTag,
    Now? now,
    Uuid? uuid,
    List<int>? randomBytes,
  }) async {
    final encryptedMessage = nip04.encryptNip04(
      content: content,
      peerPubkey: publicKey,
      privateKey: privateKey,
    );

    assert(
      nip04.decryptNip04(
            content: encryptedMessage,
            peerPubkey: publicKey,
            privateKey: privateKey,
          ) ==
          content,
      'Decrypt message should be equal to original content',
    );

    final dTagValue = dTag ?? (uuid ?? const Uuid()).v1();

    final List<List<String>> tags = [
      AppConfig.clientTagList(),
      [Tag.t.name, AppConfig.clientTagValue],
      [Tag.d.name, dTagValue],
      [
        Tag.p.name,
        publicKey,
      ],
    ];

    final createdAt = (now ?? const Now()).now();

    final event = NostrEventCreator.createEvent(
      kind: 4,
      content: encryptedMessage,
      createdAt: createdAt,
      tags: tags,
      pubkey: publicKey,
      privateKey: privateKey,
      randomBytes: randomBytes,
    );

    for (final relay in relaysListRepo.getRelaysList()) {
      nostrClient.addRelay(relay);
    }

    await nostrClient.connect();

    final result = await nostrClient.publishEventToAll(event);

    final timeoutError = result.timeoutError;

    return EventPublisherResult(
      reports: result.events
          .map(
            (e) => PublishReport(
              relay: e.relay,
              errorMessage: e.message,
            ),
          )
          .toList(),
      timeoutError: timeoutError == null
          ? null
          : PublishTimeoutError(parentError: timeoutError),
    );
  }
}
