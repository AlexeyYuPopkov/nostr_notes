import 'package:common/l10n/localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:common/app/theme/sizes.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/bloc/settings_screen_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/settings_screen_routes.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:common/presentation/tools/list_item_position.dart';

import '../bloc/settings_screen_event.dart';

abstract class SettingsItem extends Equatable {
  static const items = [
    SettingsItemPreferences(),
    SettingsItemHelp(),
    SettingsItemContacts(),
    SettingsItemDonateLightning(),
    SettingsItemBuyMeACoffee(),
    SettingsItemLogout(),
    SettingsItemLogoutAndClear(),
    DeleteAcc(),
  ];

  const SettingsItem();

  String getTitle(BuildContext context);

  Color? getTitleTextColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  void onTap(BuildContext context);

  Widget trailing(BuildContext context);

  ListItemPosition get position;
  String getSectionTitle(BuildContext context);

  @override
  List<Object?> get props => [];

  String getInfoText(BuildContext context) => '';
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

  @override
  String getSectionTitle(BuildContext context) {
    return context.l10n.settingsItemPreferences;
  }

  @override
  ListItemPosition get position => .first;
}

final class SettingsItemHelp extends SettingsItem {
  const SettingsItemHelp();
  @override
  String getTitle(context) => context.l10n.settingsItemHelp;

  @override
  void onTap(BuildContext context) {
    RouteHandler.of(context)?.onRoute(const HelpScreenRoute(), context);
  }

  @override
  Widget trailing(BuildContext context) {
    return const Icon(Icons.arrow_forward_ios, size: Sizes.iconSmall);
  }

  @override
  String getSectionTitle(BuildContext context) {
    return context.l10n.settingsScreenSectionSettingsTitle;
  }

  @override
  ListItemPosition get position => .middle;
}

final class SettingsItemContacts extends SettingsItem {
  const SettingsItemContacts();
  @override
  String getTitle(context) => context.l10n.settingsItemContacts;

  @override
  void onTap(BuildContext context) {
    RouteHandler.of(context)?.onRoute(const ContactsScreenRoute(), context);
  }

  @override
  Widget trailing(BuildContext context) {
    return const Icon(Icons.arrow_forward_ios, size: Sizes.iconSmall);
  }

  @override
  String getSectionTitle(BuildContext context) => '';

  @override
  ListItemPosition get position => .middle;
}

final class SettingsItemDonateLightning extends SettingsItem {
  const SettingsItemDonateLightning();

  @override
  String getTitle(BuildContext context) => context.l10n.settingsItemDonateBTC;

  @override
  void onTap(BuildContext context) {
    RouteHandler.of(context)?.onRoute(const DonateLightningRoute(), context);
  }

  @override
  Widget trailing(BuildContext context) =>
      const Icon(Icons.arrow_forward_ios, size: Sizes.iconSmall);

  @override
  String getSectionTitle(BuildContext context) => '';

  @override
  ListItemPosition get position => .middle;
}

final class SettingsItemBuyMeACoffee extends SettingsItem {
  const SettingsItemBuyMeACoffee();

  static final _uri = Uri.parse(AppConfig.kKofiUrl);

  @override
  String getTitle(context) => context.l10n.settingsItemBuyMeACoffee;

  @override
  void onTap(BuildContext context) {
    url_launcher.launchUrl(
      _uri,
      mode: url_launcher.LaunchMode.externalApplication,
    );
  }

  @override
  Widget trailing(BuildContext context) => const SizedBox();

  @override
  String getSectionTitle(BuildContext context) => '';

  @override
  ListItemPosition get position => .last;
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

  @override
  String getSectionTitle(BuildContext context) {
    return context.l10n.settingsScreenSectionSessionTitle;
  }

  @override
  ListItemPosition get position => .single;
}

final class SettingsItemLogoutAndClear extends SettingsItem with DialogHelper {
  const SettingsItemLogoutAndClear();
  @override
  String getTitle(context) => context.l10n.settingsScreenLogout;

  @override
  Color? getTitleTextColor(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  @override
  void onTap(BuildContext context) async {
    final result = await showConfirmation(
      context,
      isDestructive: true,
      title: context.commonL10n.commonAttention,
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

  @override
  String getSectionTitle(BuildContext context) {
    return context.l10n.settingsScreenSectionAccountTitle;
  }

  @override
  ListItemPosition get position => .first;

  @override
  String getInfoText(BuildContext context) =>
      context.l10n.settingsScreenLogoutDescription;
}

final class DeleteAcc extends SettingsItem with DialogHelper {
  const DeleteAcc();

  @override
  String getTitle(context) => context.l10n.settingsScreenDeleteAccount;

  @override
  Color? getTitleTextColor(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  @override
  void onTap(BuildContext context) {
    RouteHandler.of(context)?.onRoute(const DeleteAccRoute(), context);
  }

  @override
  Widget trailing(BuildContext context) => const SizedBox();

  @override
  String getSectionTitle(BuildContext context) {
    return context.l10n.settingsScreenSectionAccountTitle;
  }

  @override
  ListItemPosition get position => .last;

  @override
  String getInfoText(BuildContext context) =>
      context.l10n.settingsScreenDeleteDescription;
}
