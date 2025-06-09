import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/settings/bloc/settings_screen_bloc.dart';
import 'package:nostr_notes/auth/settings/bloc/settings_screen_state.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';

import 'items/settings_screen_item.dart';

final class SettingsScreen extends StatelessWidget with DialogHelper {
  const SettingsScreen({super.key});

  void _listener(BuildContext context, SettingsScreenState state) {
    switch (state) {
      case CommonState():
      case LoadingState():
        break;
      case ErrorState():
        showError(context, error: state.e);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsScreenTitle),
      ),
      body: SafeArea(
        child: BlocProvider(
          create: (context) => SettingsScreenBloc(),
          child: BlocConsumer<SettingsScreenBloc, SettingsScreenState>(
            listener: _listener,
            builder: (context, state) {
              return AbsorbPointer(
                absorbing: state is LoadingState,
                child: ListView.builder(
                  itemCount: SettingsItem.items.length,
                  itemBuilder: (context, item) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Sizes.indent2x,
                      ),
                      title: Text(SettingsItem.items[item].getTitle(context)),
                      onTap: () => SettingsItem.items[item].onTap(context),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
