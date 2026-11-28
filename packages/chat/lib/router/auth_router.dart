import 'package:auto_route/auto_route.dart';
import 'package:chat/auth/call/domain/models/call_direction.dart';
import 'package:chat/auth/call/presentation/call/call_screen.dart';
import 'package:chat/auth/call/presentation/incoming_call/incoming_call_listener.dart';
import 'package:chat/auth/call/presentation/incoming_call/incoming_call_screen.dart';
import 'package:chat/auth/chat/presentation/chat/chat_screen.dart';
import 'package:chat/auth/chat/presentation/chats_list/chats_list_screen.dart';
import 'package:chat/auth/chat/presentation/search_contact/search_contact_screen.dart';
import 'package:chat/auth/settings/presentation/profile/profile_screen.dart';
import 'package:chat/auth/settings/presentation/relays_list/relays_list_screen.dart';
import 'package:chat/auth/settings/presentation/settings/settings_screen.dart';
import 'package:chat/auth/home/presentation/home/home_navigation_bar.dart';
import 'package:chat/common/di/di.dart';
import 'package:chat/router/app_router.gr.dart';
import 'package:material_ui/material_ui.dart';
import 'package:webrtc_call/webrtc_call.dart';

@RoutePage()
final class AuthTabsPage extends StatelessWidget {
  const AuthTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return IncomingCallListener(
      coordinator: const IncomingCallListenerCoordinatorImpl(),
      child: AutoTabsScaffold(
        routes: const [ChatsListRoute(), SettingsRoute()],
        bottomNavigationBuilder: (context, tabsRouter) => HomeNavigationBar(
          selectedIndex: tabsRouter.activeIndex,
          onTabSelected: tabsRouter.setActiveIndex,
        ),
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
  Widget build(BuildContext context) => ScaffoldMessenger(
    child: ChatScreen(
      pubkey: pubkey,
      coordinator: const ChatScreenCoordinatorImpl(),
    ),
  );
}

@RoutePage()
final class CallPage extends StatelessWidget {
  final String peerPubkey;
  final CallMedia media;
  final CallDirection direction;

  const CallPage({
    super.key,
    required this.peerPubkey,
    required this.media,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) =>
      CallScreen(peerPubkey: peerPubkey, media: media, direction: direction);
}

@RoutePage()
final class IncomingCallPage extends StatelessWidget {
  final String callerPubkey;
  final String callId;
  final CallMedia media;
  final DateTime expiresAt;

  const IncomingCallPage({
    super.key,
    required this.callerPubkey,
    required this.callId,
    required this.media,
    required this.expiresAt,
  });

  @override
  Widget build(BuildContext context) => IncomingCallScreen(
    callerPubkey: callerPubkey,
    callId: callId,
    media: media,
    expiresAt: expiresAt,
    coordinator: const IncomingCallScreenCoordinatorImpl(),
  );
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

@RoutePage()
final class RelaysListPage extends StatelessWidget {
  const RelaysListPage({super.key});

  @override
  Widget build(BuildContext context) => const RelaysListScreen();
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

final class ChatScreenCoordinatorImpl implements ChatScreenCoordinator {
  const ChatScreenCoordinatorImpl();

  @override
  Future<void> onCallRoute(
    BuildContext context, {
    required String peerPubkey,
    required CallMedia media,
  }) async {
    await context.router.root.push(
      CallRoute(
        peerPubkey: peerPubkey,
        media: media,
        direction: CallDirection.outgoing,
      ),
    );
  }
}

final class IncomingCallListenerCoordinatorImpl
    implements IncomingCallListenerCoordinator {
  static const _callRouteNames = {CallRoute.name, IncomingCallRoute.name};

  const IncomingCallListenerCoordinatorImpl();

  // An invite during a call is not shown: the session turns the second
  // caller's offer down as busy.
  @override
  Future<void> onIncomingCall(
    BuildContext context, {
    required String callerPubkey,
    required String callId,
    required CallMedia media,
    required DateTime expiresAt,
  }) async {
    final root = context.router.root;
    if (_callRouteNames.contains(root.current.name)) return;
    await root.push(
      IncomingCallRoute(
        callerPubkey: callerPubkey,
        callId: callId,
        media: media,
        expiresAt: expiresAt,
      ),
    );
  }
}

final class IncomingCallScreenCoordinatorImpl
    implements IncomingCallScreenCoordinator {
  const IncomingCallScreenCoordinatorImpl();

  // The ringing screen is swapped for the call, so the call closes back to
  // wherever the invite found the user.
  @override
  Future<void> onAccepted(
    BuildContext context, {
    required String callerPubkey,
    required CallMedia media,
  }) async {
    await context.router.root.replace(
      CallRoute(
        peerPubkey: callerPubkey,
        media: media,
        direction: CallDirection.incoming,
      ),
    );
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

  // Like the profile, the relays list covers the tab bar.
  @override
  Future<void> onRelaysListRoute(BuildContext context) async {
    await context.router.root.push(const RelaysListRoute());
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
