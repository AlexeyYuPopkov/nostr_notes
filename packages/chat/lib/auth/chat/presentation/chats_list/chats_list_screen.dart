import 'package:chat/auth/chat/domain/models/chat_room.dart';
import 'package:chat/auth/chat/presentation/chats_list/provider/chats_list_provider.dart';
import 'package:chat/auth/chat/presentation/chats_list/widgets/chat_room_cell.dart';
import 'package:chat/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:flutter/material.dart';
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
    final rooms = ref.watch(chatsListProvider);

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
      body: switch (rooms) {
        AsyncData(:final value) when value.isEmpty => _EmptyChatsList(
          coordinator: coordinator,
        ),
        AsyncData(:final value) => _ChatsList(
          rooms: value,
          coordinator: coordinator,
        ),
        AsyncError() => Center(child: Text(context.l10n.chatsListLoadError)),
        _ => const Center(child: CircularProgressIndicator.adaptive()),
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
          room: room,
          onTap: () =>
              coordinator.onChatRoute(context, pubkey: room.peer.pubkey),
        );
      },
    );
  }
}
