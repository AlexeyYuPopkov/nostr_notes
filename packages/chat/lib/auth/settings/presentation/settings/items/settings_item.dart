import 'dart:async';

import 'package:chat/auth/settings/presentation/settings/settings_screen.dart';
import 'package:chat/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/tools/list_item_position.dart';
import 'package:flutter/material.dart';

sealed class SettingsItem {
  /// The rounded blocks of the screen, in order.
  static const sections = <List<SettingsItem>>[
    [SettingsItemProfile()],
  ];

  static List<(SettingsItem, ListItemPosition)> get positionedItems => [
    for (final section in sections)
      for (final (index, item) in section.indexed)
        (item, ListItemPosition.fromIndex(index, length: section.length)),
  ];

  const SettingsItem();

  String get semanticsId;

  String title(BuildContext context);

  Widget? get trailing => null;

  void onTap(BuildContext context, SettingsScreenCoordinator coordinator);
}

final class SettingsItemProfile extends SettingsItem {
  const SettingsItemProfile();

  @override
  String get semanticsId => 'SettingsScreen.profileItem';

  @override
  String title(BuildContext context) => context.l10n.settingsItemProfile;

  @override
  Widget get trailing =>
      const Icon(Icons.arrow_forward_ios, size: Sizes.iconSmall);

  @override
  void onTap(BuildContext context, SettingsScreenCoordinator coordinator) {
    unawaited(coordinator.onProfileRoute(context));
  }
}
