import 'package:chat/auth/chat/data/direct_messages/direct_message_crypto.dart';
import 'package:chat/auth/chat/data/direct_messages/direct_message_tags.dart';
import 'package:chat/auth/chat/data/direct_messages/direct_message_writer.dart';
import 'package:chat/auth/chat/data/direct_messages/direct_messages_reader.dart';
import 'package:chat/auth/chat/data/direct_messages/direct_messages_sync_usecase_impl.dart';
import 'package:chat/auth/chat/data/direct_messages/edit_chat_message_usecase_impl.dart';
import 'package:chat/auth/chat/data/direct_messages/get_chat_messages_usecase_impl.dart';
import 'package:chat/auth/chat/data/direct_messages/get_chat_rooms_usecase_impl.dart';
import 'package:chat/auth/chat/data/direct_messages/send_call_invite_usecase_impl.dart';
import 'package:chat/auth/chat/data/direct_messages/chat_message_body_codec.dart';
import 'package:chat/auth/chat/data/direct_messages/send_chat_message_usecase_impl.dart';
import 'package:chat/auth/chat/data/direct_messages/watch_call_notices_usecase_impl.dart';
import 'package:chat/auth/chat/data/direct_messages/watch_incoming_call_invites_usecase_impl.dart';
import 'package:chat/auth/chat/domain/models/chat_exception.dart';
import 'package:chat/auth/chat/domain/models/chat_message.dart';
import 'package:chat/auth/chat/domain/models/chat_message_body.dart';
import 'package:chat/auth/chat/domain/models/chat_room.dart';
import 'package:chat/common/domain/models/session.dart';
import 'package:chat/common/domain/usecase/session_usecase.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/database/daos/nostr_event_dao.dart';
import 'package:common/services/event_store/drift_event_store.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:common/services/outbox/outbox_publisher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/tag/tag_value.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr/nostr_client/nostr_event_creator.dart';
import 'package:webrtc_call/webrtc_call.dart';

import '../../../../tools/nostr/direct_message_fixtures.dart';
import '../../../../tools/nostr/fake_relay.dart';

class _MockConnectivity extends Mock implements Connectivity {}

final class _FakeRelaysListRepo implements RelaysListRepo {
  @override
  Set<String> getRelaysList() => {FakeRelay.url};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _inviteLifetime = Duration(seconds: 45);

void main() {
  late AppDatabase db;
  late RawEventStore store;
  late FakeRelay relay;
  late NostrClient client;
  late OutboxPublisher outboxPublisher;
  late DirectMessagesSyncUsecaseImpl sync;
  late UserKeys me;
  late UserKeys alice;
  late DateTime now;

  late SendChatMessageUsecaseImpl send;
  late EditChatMessageUsecaseImpl edit;
  late SendCallInviteUsecaseImpl sendInvite;
  late WatchIncomingCallInvitesUsecaseImpl watchInvites;
  late WatchCallNoticesUsecaseImpl watchNotices;
  late GetChatMessagesUsecaseImpl getMessages;
  late GetChatRoomsUsecaseImpl getRooms;

  setUp(() async {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    store = DriftEventStore(dao: NostrEventDao(db));
    relay = FakeRelay();
    client = NostrClient(channelFactory: relay.channelFactory);
    me = generateKeys();
    alice = generateKeys();
    now = DateTime(2026, 11, 5, 12);

    final session = SessionUsecase();
    await session.setSession(Session.auth(me));
    final relaysListRepo = _FakeRelaysListRepo();
    final connectivity = _MockConnectivity();
    when(
      () => connectivity.onConnectivityChanged,
    ).thenAnswer((_) => const Stream.empty());
    outboxPublisher = OutboxPublisher(
      outboxDao: db.outboxDao,
      rawEventStore: store,
      relaysListRepo: relaysListRepo,
      client: client,
      connectivity: connectivity,
    );
    sync = DirectMessagesSyncUsecaseImpl(
      sessionUsecase: session,
      client: client,
      relaysListRepo: relaysListRepo,
      eventStore: store,
      outboxPublisher: outboxPublisher,
    );

    final crypto = DirectMessageCrypto();
    final writer = DirectMessageWriter(
      database: db,
      eventStore: store,
      outboxDao: db.outboxDao,
      crypto: crypto,
    );
    final reader = DirectMessagesReader(
      eventStore: store,
      outboxDao: db.outboxDao,
      crypto: crypto,
    );
    send = SendChatMessageUsecaseImpl(
      sessionUsecase: session,
      writer: writer,
      now: () => now,
    );
    sendInvite = SendCallInviteUsecaseImpl(
      sessionUsecase: session,
      writer: writer,
      now: () => now,
    );
    watchInvites = WatchIncomingCallInvitesUsecaseImpl(
      sessionUsecase: session,
      reader: reader,
      sync: sync,
      inviteLifetime: _inviteLifetime,
      now: () => now,
    );
    watchNotices = WatchCallNoticesUsecaseImpl(
      sessionUsecase: session,
      reader: reader,
      sync: sync,
    );
    edit = EditChatMessageUsecaseImpl(
      sessionUsecase: session,
      eventStore: store,
      writer: writer,
      now: () => now,
    );
    getMessages = GetChatMessagesUsecaseImpl(
      sessionUsecase: session,
      reader: reader,
      sync: sync,
    );
    getRooms = GetChatRoomsUsecaseImpl(
      sessionUsecase: session,
      reader: reader,
      sync: sync,
    );

    addTearDown(() async {
      await sync.dispose();
      await outboxPublisher.dispose();
      await client.disconnectAndDispose();
      await session.dispose();
      await db.close();
    });
  });

  Future<List<NostrEvent>> storedMessages() => store.queryEvents(
    DirectMessageTags.sentBy(me.publicKey, to: alice.publicKey),
  );

  Future<List<String?>> lastMessagesOfRooms() => getRooms
      .execute()
      .firstWhere((rooms) => rooms.isNotEmpty)
      .timeout(const Duration(seconds: 5))
      .then((rooms) => [for (final room in rooms) room.lastMessage.text]);

  Future<List<ChatMessage>> messagesWhen(
    bool Function(List<ChatMessage>) condition,
  ) => getMessages
      .execute(peerPubkey: alice.publicKey)
      .firstWhere(condition)
      .timeout(const Duration(seconds: 5));

  group('sending', () {
    test('stores an encrypted message addressed to the peer', () async {
      await send.execute(peerPubkey: alice.publicKey, text: ' Hello ');

      final [event] = await storedMessages();
      expect(event.content, isNot(contains('Hello')));
      expect(event.tags, contains(equals([TagValue.p, alice.publicKey])));
      expect(event.tags.map((tag) => tag.first), contains(TagValue.d));
      expect(event.tags, contains(equals([TagValue.client, '996e10ba'])));
      expect(await readDirectMessage(event, as: alice), 'Hello');
    });

    test('is sending until the outbox delivers it, then sent', () async {
      await send.execute(peerPubkey: alice.publicKey, text: 'Hello');

      final [pending] = await messagesWhen((m) => m.isNotEmpty);
      expect(pending.delivery, ChatMessageDelivery.sending);

      await outboxPublisher.init();
      final [delivered] = await messagesWhen(
        (m) => m.single.delivery == ChatMessageDelivery.sent,
      );
      expect(delivered.text, 'Hello');
      expect(relay.events.map((e) => e.id), contains(delivered.eventId));
    });

    test('rejects an empty message', () {
      expect(
        () => send.execute(peerPubkey: alice.publicKey, text: '  '),
        throwsA(isA<ChatEmptyMessageException>()),
      );
    });
  });

  group('editing', () {
    test('replaces the message and keeps when it was first sent', () async {
      await send.execute(peerPubkey: alice.publicKey, text: 'Helo');
      final [original] = await messagesWhen((m) => m.isNotEmpty);

      await edit.execute(message: original, text: 'Hello');

      final [edited] = await messagesWhen((m) => m.single.text == 'Hello');
      expect(edited.id, original.id);
      expect(edited.publishedAt, original.publishedAt);
      expect(edited.editedAt, isNotNull);
      final [event] = await storedMessages();
      expect(event.id, edited.eventId);
    });

    test('drops the replaced version from the outbox', () async {
      await send.execute(peerPubkey: alice.publicKey, text: 'Helo');
      final [original] = await messagesWhen((m) => m.isNotEmpty);

      await edit.execute(message: original, text: 'Hello');

      final pending = await db.outboxDao.getPending();
      expect(
        pending.map((row) => row.eventId),
        isNot(contains(original.eventId)),
      );
      expect(pending, hasLength(1));
    });

    test(
      'is newer than the previous version even with the clock behind',
      () async {
        await send.execute(peerPubkey: alice.publicKey, text: 'Helo');
        final [original] = await messagesWhen((m) => m.isNotEmpty);
        final [before] = await storedMessages();

        now = now.subtract(const Duration(hours: 1));
        await edit.execute(message: original, text: 'Hello');

        final [after] = await storedMessages();
        expect(after.createdAt, greaterThan(before.createdAt));
      },
    );

    test("refuses to edit the peer's message", () async {
      relay.publish(
        await directMessage(from: alice, to: me.publicKey, text: 'Hi'),
      );
      final [received] = await messagesWhen((m) => m.isNotEmpty);

      expect(
        () => edit.execute(message: received, text: 'Changed'),
        throwsA(isA<ChatNotMyMessageException>()),
      );
    });
  });

  group('call invites', () {
    test('an invite reads back with its call id and media', () async {
      final callId = await sendInvite.execute(
        peerPubkey: alice.publicKey,
        media: CallMedia.video,
      );

      final [message] = await messagesWhen((m) => m.isNotEmpty);
      expect(
        message.body,
        ChatCallInvite(callId: callId, media: CallMedia.video),
      );
      expect(message.text, isNull);
    });

    test('the peer reads the invite too', () async {
      await sendInvite.execute(
        peerPubkey: alice.publicKey,
        media: CallMedia.audio,
      );

      final [event] = await storedMessages();
      final [received] = await DirectMessageCrypto().decrypt(
        keys: alice,
        events: [event],
      );
      expect(received.body, isA<ChatCallInvite>());
    });

    test('an invite cannot be edited', () async {
      await sendInvite.execute(
        peerPubkey: alice.publicKey,
        media: CallMedia.audio,
      );
      final [invite] = await messagesWhen((m) => m.isNotEmpty);

      expect(
        () => edit.execute(message: invite, text: 'Changed'),
        throwsA(isA<ChatNotEditableException>()),
      );
    });
  });

  group('incoming call invites', () {
    Future<NostrEvent> inviteFromAlice({
      required String callId,
      required DateTime at,
    }) => directMessage(
      from: alice,
      to: me.publicKey,
      text: ChatMessageBodyCodec.encode(
        ChatCallInvite(callId: callId, media: CallMedia.video),
      ),
      createdAt: at,
    );

    test('a fresh invite from the peer rings once', () async {
      final invites = <ChatMessage>[];
      final subscription = watchInvites.execute().listen(invites.add);
      addTearDown(subscription.cancel);

      relay.publish(await inviteFromAlice(callId: 'fresh', at: now));
      relay.publish(
        await directMessage(from: alice, to: me.publicKey, text: 'Hi'),
      );
      await getMessages
          .execute(peerPubkey: alice.publicKey)
          .firstWhere((m) => m.length == 2)
          .timeout(const Duration(seconds: 5));
      await pumpEventQueue();

      expect(invites.map((m) => m.body), [
        const ChatCallInvite(callId: 'fresh', media: CallMedia.video),
      ]);
    });

    test('an invite the caller gave up on does not ring', () async {
      final invites = <ChatMessage>[];
      final subscription = watchInvites.execute().listen(invites.add);
      addTearDown(subscription.cancel);

      relay.publish(
        await inviteFromAlice(
          callId: 'stale',
          at: now.subtract(_inviteLifetime + const Duration(seconds: 1)),
        ),
      );
      await getMessages
          .execute(peerPubkey: alice.publicKey)
          .firstWhere((m) => m.isNotEmpty)
          .timeout(const Duration(seconds: 5));
      await pumpEventQueue();

      expect(invites, isEmpty);
    });

    test('an invite already cancelled does not ring', () async {
      final invites = <ChatMessage>[];
      final subscription = watchInvites.execute().listen(invites.add);
      addTearDown(subscription.cancel);

      relay
        ..publish(await inviteFromAlice(callId: 'short', at: now))
        ..publish(
          await directMessage(
            from: alice,
            to: me.publicKey,
            text: ChatMessageBodyCodec.encode(const ChatCallCancel('short')),
            createdAt: now,
          ),
        );
      await getMessages
          .execute(peerPubkey: alice.publicKey)
          .firstWhere((m) => m.length == 2)
          .timeout(const Duration(seconds: 5));
      await pumpEventQueue();

      expect(invites, isEmpty);
    });

    test('notices about the call reach the caller', () async {
      final notices = <ChatCallNotice>[];
      final subscription = watchNotices
          .execute(peerPubkey: alice.publicKey, callId: 'mine')
          .listen(notices.add);
      addTearDown(subscription.cancel);

      for (final notice in [
        const ChatCallDecline('other'),
        const ChatCallDecline('mine'),
      ]) {
        relay.publish(
          await directMessage(
            from: alice,
            to: me.publicKey,
            text: ChatMessageBodyCodec.encode(notice),
            createdAt: now,
          ),
        );
      }
      await getMessages
          .execute(peerPubkey: alice.publicKey)
          .firstWhere((m) => m.length == 2)
          .timeout(const Duration(seconds: 5));
      await pumpEventQueue();

      expect(notices, [const ChatCallDecline('mine')]);
    });

    test('my own invite does not ring', () async {
      final invites = <ChatMessage>[];
      final subscription = watchInvites.execute().listen(invites.add);
      addTearDown(subscription.cancel);

      await sendInvite.execute(
        peerPubkey: alice.publicKey,
        media: CallMedia.audio,
      );
      await messagesWhen((m) => m.isNotEmpty);
      await pumpEventQueue();

      expect(invites, isEmpty);
    });
  });

  group('receiving', () {
    test(
      'a message from the relay is decrypted into the conversation',
      () async {
        relay.publish(
          await directMessage(from: alice, to: me.publicKey, text: 'Hi'),
        );

        final [message] = await messagesWhen((m) => m.isNotEmpty);
        expect(message.text, 'Hi');
        expect(message.authorPubkey, alice.publicKey);
      },
    );

    test('a message sent while the chat is open arrives live', () async {
      final empty = getMessages.execute(peerPubkey: alice.publicKey);
      expect(await empty.first, isEmpty);

      relay.publish(
        await directMessage(from: alice, to: me.publicKey, text: 'Live'),
      );

      final [message] = await messagesWhen((m) => m.isNotEmpty);
      expect(message.text, 'Live');
    });

    test('a message I cannot decrypt is left out', () async {
      final stranger = generateKeys();
      final forAlice = await directMessage(
        from: stranger,
        to: alice.publicKey,
        text: 'Secret',
      );
      relay.publish(
        const NostrEventCreator().createEvent(
          kind: forAlice.kind,
          content: forAlice.content,
          createdAt: DateTime.now(),
          tags: [
            for (final tag in forAlice.tags)
              tag.first == TagValue.p ? [TagValue.p, me.publicKey] : tag,
          ],
          pubkey: stranger.publicKey,
          privateKey: stranger.privateKey,
        ),
      );
      relay.publish(
        await directMessage(from: alice, to: me.publicKey, text: 'Readable'),
      );

      expect(await lastMessagesOfRooms(), ['Readable']);
    });

    test('a forged message is left out', () async {
      final genuine = await directMessage(
        from: alice,
        to: me.publicKey,
        text: 'Genuine',
      );
      final forged = await directMessage(
        from: generateKeys(),
        to: me.publicKey,
        text: 'Forged',
      );
      relay.publish(
        NostrEvent(
          kind: forged.kind,
          id: forged.id,
          pubkey: alice.publicKey,
          createdAt: forged.createdAt,
          tags: forged.tags,
          content: forged.content,
          sig: forged.sig,
        ),
      );
      relay.publish(genuine);

      expect(await lastMessagesOfRooms(), ['Genuine']);
    });
  });

  group('rooms', () {
    test('one room per peer with its newest message', () async {
      relay.publish(
        await directMessage(
          from: alice,
          to: me.publicKey,
          text: 'First',
          createdAt: now.subtract(const Duration(minutes: 5)),
        ),
      );
      await send.execute(peerPubkey: alice.publicKey, text: 'Second');

      final [room] = await getRooms
          .execute()
          .firstWhere(
            (rooms) =>
                rooms.length == 1 && rooms.single.lastMessage.text == 'Second',
          )
          .timeout(const Duration(seconds: 5));
      expect(room.peerPubkey, alice.publicKey);
    });

    test('newest conversation first', () async {
      final bob = generateKeys();
      relay.publish(
        await directMessage(
          from: alice,
          to: me.publicKey,
          text: 'Older',
          createdAt: now.subtract(const Duration(hours: 1)),
        ),
      );
      relay.publish(
        await directMessage(from: bob, to: me.publicKey, text: 'Newer'),
      );

      final rooms = await getRooms
          .execute()
          .firstWhere((rooms) => rooms.length == 2)
          .timeout(const Duration(seconds: 5));
      expect(rooms.map((ChatRoom room) => room.lastMessage.text), [
        'Newer',
        'Older',
      ]);
    });
  });
}
