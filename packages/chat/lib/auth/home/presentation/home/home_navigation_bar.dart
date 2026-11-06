import 'package:chat/l10n/localization.dart';
import 'package:flutter/material.dart';

final class HomeNavigationBar extends StatelessWidget {
  static const chatsTabSemanticsId = 'AuthTabs.chats';
  static const settingsTabSemanticsId = 'AuthTabs.settings';

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const HomeNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onTabSelected,
      destinations: [
        NavigationDestination(
          icon: Semantics(
            identifier: chatsTabSemanticsId,
            child: const Icon(Icons.chat_bubble_outline),
          ),
          label: context.l10n.tabChats,
        ),
        NavigationDestination(
          icon: Semantics(
            identifier: settingsTabSemanticsId,
            child: const Icon(Icons.settings_outlined),
          ),
          label: context.l10n.tabSettings,
        ),
      ],
    );
  }
}
