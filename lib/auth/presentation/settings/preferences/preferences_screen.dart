import 'package:flutter/material.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/presentation/settings/preferences/bloc/items/preferences_item.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';

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
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(),
      body: SafeArea(
        child: ListView.builder(
          itemCount: PreferencesItem.items.length,
          itemBuilder: (context, index) {
            final item = PreferencesItem.items[index];
            return ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.indent),
                child: Text(item.getTitle(context)),
              ),
              trailing: item.trailing(context),
              onTap: () => item.onTap(context),
            );
          },
        ),
      ),
      // ),
    );
  }
}
