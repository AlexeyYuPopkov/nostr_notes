import 'package:chat/auth/chat/domain/usecase/get_user_usecase.dart';
import 'package:chat/auth/common/data/model/nostr_kind.dart';
import 'package:common/data/mappers/user_mapper.dart';
import 'package:common/domain/model/user.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/nostr_event.dart';

final class GetUserUseCaseImpl implements GetUserUseCase {
  final RawEventStore _eventStore;

  const GetUserUseCaseImpl({required this._eventStore});

  @override
  Stream<User> execute({required String pubkey}) {
    return _eventStore
        .watchEvents(
          RawEventQuery(kinds: const [NostrKind.user], authors: [pubkey]),
        )
        .map((events) => _newestUser(pubkey, events))
        .distinct();
  }

  static User _newestUser(String pubkey, Iterable<NostrEvent> events) {
    if (events.isEmpty) {
      return User(pubkey: pubkey);
    }
    final newest = events.reduce((a, b) => a.createdAt >= b.createdAt ? a : b);
    return UserMapper.fromNostrEvent(newest) ?? User(pubkey: pubkey);
  }
}
