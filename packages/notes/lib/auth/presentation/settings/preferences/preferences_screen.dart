import 'package:common/app/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/auth/presentation/settings/preferences/bloc/items/preferences_item.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class PreferencesScreen extends StatelessWidget with DialogHelper {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsItemPreferences),
        toolbarHeight: Sizes.appBarHeight,
      ),
      body: ListView.builder(
        itemCount: PreferencesItem.items.length,
        itemBuilder: (context, index) {
          final item = PreferencesItem.items[index];

          return SettingsItemTile(
            title: Text(item.getTitle(context)),
            position: item.position,

            trailing: item.trailing(context),
            onTap: () => item.onTap(context),
          );
        },
      ),
      // ),
    );
  }
}
