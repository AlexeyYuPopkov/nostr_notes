import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/settings_screen_routes.dart';
import 'package:nostr_notes/common/presentation/tools/list_item_position.dart';

sealed class PreferencesItem {
  static final List<PreferencesItem> items = [
    const ThemePreferencesItem(),
    const RelaysList(),
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
      const MobileKeyboardType(),
    const CredentialsDataPreferencesItem(),
  ];

  const PreferencesItem();

  String getSectionTitle(BuildContext context) => '';

  String getTitle(BuildContext context);

  FutureOr<dynamic> onTap(BuildContext context);

  Widget trailing(BuildContext context);

  ListItemPosition get position;
}

final class ThemePreferencesItem extends PreferencesItem {
  const ThemePreferencesItem();

  @override
  String getSectionTitle(BuildContext context) =>
      context.l10n.settingsItemPreferences;

  @override
  String getTitle(BuildContext context) {
    return context.l10n.themeScreenTitle;
  }

  @override
  FutureOr<dynamic> onTap(BuildContext context) {
    RouteHandler.of(context)?.onRoute(const ThemeSettingsRoute(), context);
  }

  @override
  Widget trailing(BuildContext context) {
    return const Icon(Icons.arrow_forward_ios, size: Sizes.iconSmall);
  }

  @override
  ListItemPosition get position => .first;
}

final class RelaysList extends PreferencesItem {
  const RelaysList();

  @override
  String getTitle(BuildContext context) {
    return context.l10n.preferencesScreenItemRelays;
  }

  @override
  FutureOr<dynamic> onTap(BuildContext context) {
    RouteHandler.of(context)?.onRoute(const RelaysListRoute(), context);
  }

  @override
  Widget trailing(BuildContext context) {
    return const Icon(Icons.arrow_forward_ios, size: Sizes.iconSmall);
  }

  @override
  ListItemPosition get position => .middle;
}

final class MobileKeyboardType extends PreferencesItem {
  const MobileKeyboardType();

  @override
  String getTitle(BuildContext context) {
    return context.l10n.preferencesScreenItemMobilePinKeyboardType;
  }

  @override
  FutureOr<dynamic> onTap(BuildContext context) {
    RouteHandler.of(context)?.onRoute(const PinKeyboardTypeRoute(), context);
  }

  @override
  Widget trailing(BuildContext context) {
    return const Icon(Icons.arrow_forward_ios, size: Sizes.iconSmall);
  }

  @override
  ListItemPosition get position => .middle;
}

final class CredentialsDataPreferencesItem extends PreferencesItem {
  const CredentialsDataPreferencesItem();

  @override
  String getTitle(BuildContext context) {
    return context.l10n.credentialsDataScreenTitle;
  }

  @override
  FutureOr<dynamic> onTap(BuildContext context) {
    RouteHandler.of(context)?.onRoute(const CredentialsDataRoute(), context);
  }

  @override
  Widget trailing(BuildContext context) {
    return const Icon(Icons.arrow_forward_ios, size: Sizes.iconSmall);
  }

  @override
  ListItemPosition get position => .last;
}
