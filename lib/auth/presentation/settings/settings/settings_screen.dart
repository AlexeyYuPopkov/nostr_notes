import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/router/app_route/app_route.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/bloc/settings_screen_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/bloc/settings_screen_state.dart';
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
      appBar: AppBar(title: Text(context.l10n.settingsScreenTitle)),
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
                  itemBuilder: (context, index) {
                    final item = SettingsItem.items[index];
                    return ListTile(
                      title: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.indent,
                        ),
                        child: Text(
                          item.getTitle(context),
                          style: item.getTitleTextStyle(context),
                        ),
                      ),
                      trailing: item.trailing(context),
                      onTap: () => item.onTap(context),
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

final class PreferencesRoute implements AppRoute {
  const PreferencesRoute();
}

final class RelaysListRoute implements AppRoute {
  const RelaysListRoute();
}

final class PinKeyboardTypeRoute implements AppRoute {
  const PinKeyboardTypeRoute();
}

final class CredentialsDataRoute implements AppRoute {
  const CredentialsDataRoute();
}
