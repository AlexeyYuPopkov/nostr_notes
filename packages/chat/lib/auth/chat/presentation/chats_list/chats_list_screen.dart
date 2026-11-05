import 'package:chat/auth/chat/presentation/chats_list/provider/chats_list_provider.dart';
import 'package:chat/auth/chat/domain/models/chat.dart';
import 'package:chat/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class ChatsListScreenCoordinator {
  Future<void> onChatRoute(BuildContext context, {required String pubkey});

  Future<void> onSearchContactRoute(BuildContext context);
}

final class ChatsListScreen extends ConsumerWidget {
  static const searchContactButtonSemanticsId =
      'ChatsListScreen.searchContactButton';

  final ChatsListScreenCoordinator coordinator;

  const ChatsListScreen({super.key, required this.coordinator});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatsListProvider);

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
      body: switch (chats) {
        AsyncData(:final value) when value.isEmpty => Center(
          child: Text(context.l10n.chatsListEmpty),
        ),
        AsyncData(:final value) => _ChatsList(
          chats: value,
          coordinator: coordinator,
        ),
        AsyncError() => Center(child: Text(context.l10n.chatsListLoadError)),
        _ => const Center(child: CircularProgressIndicator.adaptive()),
      },
    );
  }
}

final class _ChatsList extends StatelessWidget {
  final List<Chat> chats;
  final ChatsListScreenCoordinator coordinator;

  const _ChatsList({required this.chats, required this.coordinator});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final pubkey = chats[index].pubkey;
        return ListTile(
          title: Text(pubkey, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () => coordinator.onChatRoute(context, pubkey: pubkey),
        );
      },
    );
  }
}
