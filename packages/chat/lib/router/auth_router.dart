import 'package:auto_route/auto_route.dart';
import 'package:chat/auth/chat/presentation/chat/chat_screen.dart';
import 'package:chat/auth/chat/presentation/chats_list/chats_list_screen.dart';
import 'package:chat/auth/chat/presentation/search_contact/search_contact_screen.dart';
import 'package:chat/auth/settings/presentation/settings/settings_screen.dart';
import 'package:chat/auth/home/presentation/home/home_navigation_bar.dart';
import 'package:chat/router/app_router.gr.dart';
import 'package:flutter/material.dart';

@RoutePage()
final class AuthTabsPage extends StatelessWidget {
  const AuthTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [ChatsListRoute(), SettingsRoute()],
      bottomNavigationBuilder: (context, tabsRouter) => HomeNavigationBar(
        selectedIndex: tabsRouter.activeIndex,
        onTabSelected: tabsRouter.setActiveIndex,
      ),
    );
  }
}

@RoutePage()
final class ChatsListPage extends StatelessWidget {
  const ChatsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChatsListScreen(coordinator: ChatsListScreenCoordinatorImpl());
  }
}

@RoutePage()
final class ChatPage extends StatelessWidget {
  final String pubkey;

  const ChatPage({super.key, required this.pubkey});

  @override
  Widget build(BuildContext context) => ChatScreen(pubkey: pubkey);
}

@RoutePage()
final class SearchContactPage extends StatelessWidget {
  const SearchContactPage({super.key});

  @override
  Widget build(BuildContext context) => const SearchContactScreen(
    coordinator: SearchContactScreenCoordinatorImpl(),
  );
}

@RoutePage()
final class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => const SettingsScreen();
}

final class ChatsListScreenCoordinatorImpl
    implements ChatsListScreenCoordinator {
  const ChatsListScreenCoordinatorImpl();

  // The chat covers the tab bar, so it goes onto the root stack rather than
  // the tab's own one.
  @override
  Future<void> onChatRoute(
    BuildContext context, {
    required String pubkey,
  }) async {
    await context.router.root.push(ChatRoute(pubkey: pubkey));
  }

  @override
  Future<void> onSearchContactRoute(BuildContext context) async {
    await context.router.root.push(const SearchContactRoute());
  }
}

final class SearchContactScreenCoordinatorImpl
    implements SearchContactScreenCoordinator {
  const SearchContactScreenCoordinatorImpl();

  // The modal search is swapped for the chat, so "back" from the chat
  // returns to the chats list rather than to the search.
  @override
  Future<void> onChatRoute(
    BuildContext context, {
    required String pubkey,
  }) async {
    await context.router.root.replace(ChatRoute(pubkey: pubkey));
  }
}
