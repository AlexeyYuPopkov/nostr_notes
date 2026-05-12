import 'package:flutter/material.dart';
import 'package:nostr_notes/auth/presentation/settings/preferences/bloc/items/preferences_item.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:nostr_notes/l10n/localization.dart';

import 'bloc/app_settings_state.dart';

final class PreferencesScreen extends StatelessWidget with DialogHelper {
  PreferencesScreen({super.key});

  // ignore: unused_element
  void _listener(BuildContext context, AppSettingsState state) {
    switch (state) {
      case CommonState():
        break;
      case LoadingState():
        break;
      case ErrorState():
        showError(context, error: state.e);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      // appBar: AppBar(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(title: Text(l10n.settingsItemPreferences)),
          SliverList.builder(
            itemCount: PreferencesItem.items.length,
            itemBuilder: (context, index) {
              final item = PreferencesItem.items[index];

              return SettingsItemTile(
                title: item.getTitle(context),
                position: item.position,
                sectionTitle: '',
                trailing: item.trailing(context),
                onTap: () => item.onTap(context),
              );
            },
          ),
        ],
      ),
      // ),
    );
  }
}
