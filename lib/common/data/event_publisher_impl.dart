import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/auth/domain/repo/relays_list_repo.dart';
import 'package:nostr_notes/common/domain/event_publisher.dart';
import 'package:nostr_notes/core/event_kind.dart';
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
    required String summary,
    required String publicKey,
    required String privateKey,
    required String? dTag,
    Now? now,
    Uuid? uuid,
    List<int>? randomBytes,
  }) async {
    final encryptedSummary = nip04.encryptNip04(
      content: summary,
      peerPubkey: publicKey,
      privateKey: privateKey,
    );
    final encryptedMessage = nip04.encryptNip04(
      content: content,
      peerPubkey: publicKey,
      privateKey: privateKey,
    );

    assert(
      nip04.decryptNip04(
            content: encryptedSummary,
            peerPubkey: publicKey,
            privateKey: privateKey,
          ) ==
          summary,
      'Decrypt summary should be equal to original summary',
    );

    final dTagValue = dTag ?? (uuid ?? const Uuid()).v1();

    final List<List<String>> tags = [
      AppConfig.clientTagList(),
      [Tag.t.value, AppConfig.clientTagValue],
      [Tag.d.value, dTagValue],
      [
        Tag.p.value,
        publicKey,
      ],
      [const SummaryTag().value, encryptedSummary],
    ];

    final createdAt = (now ?? const Now()).now();

    final event = NostrEventCreator.createEvent(
      kind: EventKind.note.value,
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
