import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/settings_screen.dart';

sealed class PreferencesItem {
  static const List<PreferencesItem> items = [RelaysList()];

  const PreferencesItem();

  String getTitle(BuildContext context);

  FutureOr<dynamic> onTap(BuildContext context);

  Widget trailing(BuildContext context);
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
}
