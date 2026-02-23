import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/bloc/settings_screen_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/settings_screen.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';

import '../bloc/settings_screen_event.dart';

abstract class SettingsItem {
  static const items = [
    SettingsItemPreferences(),
    SettingsItemLogout(),
    SettingsItemLogoutAndClear(),
  ];

  const SettingsItem();

  String getTitle(BuildContext context);

  void onTap(BuildContext context);

  Widget trailing(BuildContext context);
}

final class SettingsItemPreferences extends SettingsItem {
  const SettingsItemPreferences();
  @override
  String getTitle(context) => context.l10n.settingsItemPreferences;

  @override
  void onTap(BuildContext context) {
    RouteHandler.of(context)?.onRoute(const PreferencesRoute(), context);
  }

  @override
  Widget trailing(BuildContext context) {
    return const Icon(Icons.arrow_forward_ios, size: Sizes.iconSmall);
  }
}

final class SettingsItemLogout extends SettingsItem {
  const SettingsItemLogout();
  @override
  String getTitle(context) => context.l10n.settingsScreenExit;

  @override
  void onTap(BuildContext context) {
    context.read<SettingsScreenBloc>().add(const SettingsScreenEvent.exit());
  }

  @override
  Widget trailing(BuildContext context) => const SizedBox();
}

final class SettingsItemLogoutAndClear extends SettingsItem with DialogHelper {
  const SettingsItemLogoutAndClear();
  @override
  String getTitle(context) => context.l10n.settingsScreenLogout;

  @override
  void onTap(BuildContext context) async {
    final result = await showConfirmation(
      context,
      title: context.l10n.commonAttention,
      message: context.l10n.settingsScreenLogoutConfirmationMessage,
    );

    if (result == true && context.mounted) {
      context.read<SettingsScreenBloc>().add(
        const SettingsScreenEvent.logout(),
      );
    }
  }

  @override
  Widget trailing(BuildContext context) => const SizedBox();
}
