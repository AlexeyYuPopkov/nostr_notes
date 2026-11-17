import 'package:chat/auth/chat/domain/models/chat_room.dart';
import 'package:chat/auth/chat/presentation/chats_list/provider/chat_rooms_provider.dart';
import 'package:chat/auth/chat/presentation/chats_list/provider/chat_rooms_state.dart';
import 'package:chat/auth/chat/presentation/chats_list/widgets/chat_room_cell.dart';
import 'package:chat/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class ChatsListScreenCoordinator {
  Future<void> onChatRoute(BuildContext context, {required String pubkey});

  Future<void> onSearchContactRoute(BuildContext context);
}

final class ChatsListScreen extends ConsumerWidget {
  static const searchContactButtonSemanticsId =
      'ChatsListScreen.searchContactButton';
  static const startChatButtonSemanticsId = 'ChatsListScreen.startChatButton';

  final ChatsListScreenCoordinator coordinator;

  const ChatsListScreen({super.key, required this.coordinator});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatRoomsProviderProvider);
    final rooms = state.data.rooms;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.chatsListTitle),
        actions: [
          Semantics(
            identifier: searchContactButtonSemanticsId,
            child: IconButton(
              icon: const Icon(Icons.person_search),
              tooltip: context.l10n.searchContactTitle,
              onPressed: () => coordinator.onSearchContactRoute(context),
            ),
          ),
        ],
      ),
      body: switch (state) {
        _ when rooms.isNotEmpty => _ChatsList(
          rooms: rooms,
          coordinator: coordinator,
        ),
        ChatRoomsLoading() => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
        ChatRoomsError() => Center(
          child: Text(context.l10n.chatsListLoadError),
        ),
        ChatRoomsCommon() => _EmptyChatsList(coordinator: coordinator),
      },
    );
  }
}

final class _EmptyChatsList extends StatelessWidget {
  final ChatsListScreenCoordinator coordinator;

  const _EmptyChatsList({required this.coordinator});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.chatsListEmpty),
          const SizedBox(height: Sizes.indent2x),
          Semantics(
            identifier: ChatsListScreen.startChatButtonSemanticsId,
            child: FilledButton(
              onPressed: () => coordinator.onSearchContactRoute(context),
              child: Text(context.l10n.chatsListStartChat),
            ),
          ),
        ],
      ),
    );
  }
}

final class _ChatsList extends StatelessWidget {
  final List<ChatRoom> rooms;
  final ChatsListScreenCoordinator coordinator;

  const _ChatsList({required this.rooms, required this.coordinator});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        return ChatRoomCell(
          key: ValueKey(room.peerPubkey),
          room: room,
          onTap: () =>
              coordinator.onChatRoute(context, pubkey: room.peerPubkey),
        );
      },
    );
  }
}
