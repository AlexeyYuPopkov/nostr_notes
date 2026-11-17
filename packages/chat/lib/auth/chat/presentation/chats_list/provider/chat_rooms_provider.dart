import 'dart:async';

import 'package:chat/auth/chat/domain/models/chat_room.dart';
import 'package:chat/auth/chat/domain/usecase/fetch_users_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/get_chat_rooms_usecase.dart';
import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

import 'chat_rooms_data.dart';
import 'chat_rooms_state.dart';

part 'chat_rooms_provider.g.dart';

/// The rooms, plus a live relay subscription to the peers' profiles while
/// the list is open. Cells read the profiles from the store themselves.
@riverpod
final class ChatRoomsProvider extends _$ChatRoomsProvider {
  late final GetChatRoomsUsecase _getRoomsUsecase = GetIt.I.get();
  late final FetchUsersUsecase _fetchUsersUsecase = GetIt.I.get();

  final _peers = PublishSubject<Set<String>>();

  @override
  ChatRoomsState build() {
    final rooms = _getRoomsUsecase.execute().listen(
      _onRooms,
      onError: _onLoadError,
    );
    final profiles = _peers
        .distinct(const SetEquality<String>().equals)
        .switchMap(_watchProfiles)
        .listen(null);

    ref.onDispose(() {
      unawaited(rooms.cancel());
      unawaited(profiles.cancel());
      unawaited(_peers.close());
    });

    return const ChatRoomsLoading(data: ChatRoomsData.initial());
  }

  void _onRooms(List<ChatRoom> rooms) {
    state = ChatRoomsCommon(data: ChatRoomsData(rooms: rooms));
    _peers.add({for (final room in rooms) room.peerPubkey});
  }

  void _onLoadError(Object error) {
    state = ChatRoomsError(data: state.data, error: error);
  }

  /// Cells fall back to the npub, so a failed subscription only ends updates
  /// until the set of peers changes.
  Stream<void> _watchProfiles(Set<String> peers) {
    return _fetchUsersUsecase
        .execute(pubkeys: peers)
        .onErrorResume((_, _) => const Stream.empty());
  }
}
