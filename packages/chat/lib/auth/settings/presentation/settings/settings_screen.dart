import 'package:chat/auth/settings/presentation/settings/items/settings_item.dart';
import 'package:chat/l10n/localization.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';
import 'package:flutter/material.dart';

abstract interface class SettingsScreenCoordinator {
  Future<void> onProfileRoute(BuildContext context);
}

final class SettingsScreen extends StatelessWidget {
  final SettingsScreenCoordinator coordinator;

  const SettingsScreen({super.key, required this.coordinator});

  @override
  Widget build(BuildContext context) {
    final items = SettingsItem.positionedItems;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final (item, position) = items[index];
          return Semantics(
            identifier: item.semanticsId,
            child: SettingsItemTile(
              title: Text(item.title(context)),
              position: position,
              trailing: item.trailing,
              onTap: () => item.onTap(context, coordinator),
            ),
          );
        },
      ),
    );
  }
}
