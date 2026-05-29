import 'dart:async';
import 'dart:io';

import 'package:common/l10n/localization.dart';
import 'package:common/app/vm/global_settings_scope.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/settings_screen_routes.dart';
import 'package:common/presentation/tools/list_item_position.dart';

sealed class PreferencesItem {
  static final List<PreferencesItem> items = [
    const ThemePreferencesItem(),
    const RelaysList(),
    const LocalePreferencesItem(),
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
      const MobileKeyboardType(),
    const CredentialsDataPreferencesItem(),
  ];

  const PreferencesItem();

  String getTitle(BuildContext context);
  String getSectionTitle(BuildContext context) =>
      context.l10n.settingsItemPreferences;

  FutureOr<dynamic> onTap(BuildContext context);

  Widget trailing(BuildContext context);

  ListItemPosition get position;
}

final class ThemePreferencesItem extends PreferencesItem {
  const ThemePreferencesItem();

  @override
  String getTitle(BuildContext context) {
    return context.commonL10n.themeScreenTitle;
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

final class LocalePreferencesItem extends PreferencesItem {
  const LocalePreferencesItem();

  @override
  String getTitle(BuildContext context) {
    return context.l10n.preferencesScreenItemLanguage;
  }

  @override
  FutureOr<dynamic> onTap(BuildContext context) {
    RouteHandler.of(context)?.onRoute(const LocaleSettingsRoute(), context);
  }

  @override
  Widget trailing(BuildContext context) {
    final vm = GlobalSettingsScope.of(context);
    final languageCode = vm.localeNotifier.value?.languageCode;
    final label = switch (languageCode) {
      null => context.l10n.preferencesScreenLanguageSystem,
      'ru' => context.l10n.preferencesScreenLanguageRussian,
      _ => context.l10n.preferencesScreenLanguageEnglish,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(width: Sizes.halfIndent),
        const Icon(Icons.arrow_forward_ios, size: Sizes.iconSmall),
      ],
    );
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
