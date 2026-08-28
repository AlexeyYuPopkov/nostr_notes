import 'package:common/l10n/localization.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/common/presentation/layout/app_platform.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/items/donate_via_lightning/donate_via_lightning.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:common/app/theme/sizes.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/bloc/settings_screen_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/settings_screen_routes.dart';

import 'package:common/presentation/tools/list_item_position.dart';

import '../bloc/settings_screen_event.dart';

abstract class SettingsItem extends Equatable {
  /// The rounded blocks of the screen, in order. An item's corners and
  /// separators follow from where it sits in its block, so a block that
  /// gains or loses an item still closes correctly.
  static List<List<SettingsItem>> get sections => [
    [
      const SettingsItemPreferences(),
      const SettingsItemImportExport(),
      const SettingsItemHelp(),
      const SettingsItemContacts(),
      if (_isMobile) const SettingsItemLeaveReview(),
      const SettingsItemReportBug(),
      // Web and desktop, where there are no ads. The native iOS and Android
      // builds are paid for by ads already, so asking for donations on top of
      // them would be asking twice. `isMobile` is false in a browser even on
      // a phone, which is what we want: the web build carries no ads either.
      if (!_isMobile) ...[
        const SettingsItemDonateLightning(),
        const SettingsItemBuyMeACoffee(),
      ],
    ],
    [const SettingsItemLogout()],
    [const SettingsItemLogoutAndClear(), const DeleteAcc()],
  ];

  static List<(SettingsItem, ListItemPosition)> get positionedItems => [
    for (final section in sections)
      for (final (index, item) in section.indexed)
        (item, ListItemPosition.fromIndex(index, length: section.length)),
  ];

  static bool get _isMobile => const AppPlatform().isMobile;

  const SettingsItem();

  Widget getTitle(BuildContext context);

  Color? getTitleTextColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  void onTap(BuildContext context);

  Widget trailing(BuildContext context);

  String getSectionTitle(BuildContext context);

  @override
  List<Object?> get props => [];

  String getInfoText(BuildContext context) => '';
}

final class SettingsItemPreferences extends SettingsItem {
  const SettingsItemPreferences();
  @override
  Widget getTitle(BuildContext context) =>
      Text(context.l10n.settingsItemPreferences);

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
}

final class SettingsItemImportExport extends SettingsItem {
  const SettingsItemImportExport();
  @override
  String getSectionTitle(BuildContext context) => '';
  @override
  Widget getTitle(BuildContext context) =>
      Text(context.l10n.exportImportScreenTitle);

  @override
  void onTap(BuildContext context) {
    RouteHandler.of(context)?.onRoute(const ExportImportRoute(), context);
  }

  @override
  Widget trailing(BuildContext context) {
    return const Icon(Icons.arrow_forward_ios, size: Sizes.iconSmall);
  }
}

final class SettingsItemHelp extends SettingsItem {
  const SettingsItemHelp();
  @override
  Widget getTitle(BuildContext context) => Text(context.l10n.settingsItemHelp);

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
}

final class SettingsItemContacts extends SettingsItem {
  const SettingsItemContacts();
  @override
  Widget getTitle(BuildContext context) =>
      Text(context.l10n.settingsItemContacts);

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
}

final class SettingsItemLeaveReview extends SettingsItem {
  const SettingsItemLeaveReview();

  @override
  Widget getTitle(BuildContext context) =>
      Text(context.l10n.settingsItemLeaveReview);

  @override
  void onTap(BuildContext context) {
    url_launcher.launchUrl(
      Uri.parse(
        const AppPlatform().isIOS
            ? AppConfig.appStoreReviewLink
            : AppConfig.googlePlayLink,
      ),
      mode: url_launcher.LaunchMode.externalApplication,
    );
  }

  @override
  Widget trailing(BuildContext context) => const SizedBox();

  @override
  String getSectionTitle(BuildContext context) => '';
}

final class SettingsItemReportBug extends SettingsItem {
  const SettingsItemReportBug();

  static final _uri = Uri.parse(AppConfig.githubIssuesLink);

  @override
  Widget getTitle(BuildContext context) =>
      Text(context.l10n.settingsItemReportBug);

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
}

final class SettingsItemDonateLightning extends SettingsItem {
  const SettingsItemDonateLightning();

  @override
  Widget getTitle(BuildContext context) => const DonateViaLightning();

  @override
  void onTap(BuildContext context) {
    RouteHandler.of(context)?.onRoute(const DonateLightningRoute(), context);
  }

  @override
  Widget trailing(BuildContext context) =>
      const Icon(Icons.arrow_forward_ios, size: Sizes.iconSmall);

  @override
  String getSectionTitle(BuildContext context) => '';
}

final class SettingsItemBuyMeACoffee extends SettingsItem {
  const SettingsItemBuyMeACoffee();

  static final _uri = Uri.parse(AppConfig.kKofiUrl);

  @override
  Widget getTitle(BuildContext context) =>
      Text(context.l10n.settingsItemBuyMeACoffee);

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
}

final class SettingsItemLogout extends SettingsItem {
  const SettingsItemLogout();
  @override
  Widget getTitle(BuildContext context) =>
      Text(context.l10n.settingsScreenExit);

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
}

final class SettingsItemLogoutAndClear extends SettingsItem with DialogHelper {
  const SettingsItemLogoutAndClear();
  @override
  Widget getTitle(BuildContext context) =>
      Text(context.l10n.settingsScreenLogout);

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
  String getInfoText(BuildContext context) =>
      context.l10n.settingsScreenLogoutDescription;
}

final class DeleteAcc extends SettingsItem with DialogHelper {
  const DeleteAcc();

  @override
  Widget getTitle(BuildContext context) =>
      Text(context.l10n.settingsScreenDeleteAccount);

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
  String getInfoText(BuildContext context) =>
      context.l10n.settingsScreenDeleteDescription;
}
