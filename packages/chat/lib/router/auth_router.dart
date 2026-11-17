import 'package:auto_route/auto_route.dart';
import 'package:chat/auth/chat/presentation/chat/chat_screen.dart';
import 'package:chat/auth/chat/presentation/chats_list/chats_list_screen.dart';
import 'package:chat/auth/chat/presentation/search_contact/search_contact_screen.dart';
import 'package:chat/auth/settings/presentation/profile/profile_screen.dart';
import 'package:chat/auth/settings/presentation/settings/settings_screen.dart';
import 'package:chat/auth/home/presentation/home/home_navigation_bar.dart';
import 'package:chat/common/di/di.dart';
import 'package:chat/router/app_router.gr.dart';
import 'package:material_ui/material_ui.dart';

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

// Pages pushed over the tabs get their own ScaffoldMessenger: the root one
// also puts their snack bar into the Scaffolds of the routes underneath, and
// the back transition then fails on SnackBar Heroes sharing one tag.
@RoutePage()
final class ChatPage extends StatelessWidget {
  final String pubkey;

  const ChatPage({super.key, required this.pubkey});

  @override
  Widget build(BuildContext context) =>
      ScaffoldMessenger(child: ChatScreen(pubkey: pubkey));
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
  Widget build(BuildContext context) =>
      const SettingsScreen(coordinator: SettingsScreenCoordinatorImpl());
}

// See [ChatPage] for the own ScaffoldMessenger.
@RoutePage()
final class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) =>
      const ScaffoldMessenger(child: ProfileScreen());
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

final class SettingsScreenCoordinatorImpl implements SettingsScreenCoordinator {
  const SettingsScreenCoordinatorImpl();

  // Like the chat, the profile covers the tab bar.
  @override
  Future<void> onProfileRoute(BuildContext context) async {
    await context.router.root.push(const ProfileRoute());
  }

  // The auth scope goes only after the auth screens are gone: their
  // providers still listen to the database and the relay client it owns.
  @override
  Future<void> onLoggedOut(BuildContext context) async {
    await context.router.root.replaceAll([const OnboardingRoute()]);
    await WidgetsBinding.instance.endOfFrame;
    await Di.dropAuthModules();
  }
}
