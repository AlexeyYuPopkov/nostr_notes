import 'dart:async';

import 'package:chat/auth/settings/presentation/settings/settings_screen.dart';
import 'package:chat/common/domain/usecase/auth_usecase.dart';
import 'package:chat/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/l10n/localization.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:common/presentation/tools/list_item_position.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

sealed class SettingsItem {
  /// The rounded blocks of the screen, in order.
  static const sections = <List<SettingsItem>>[
    [SettingsItemProfile()],
    [SettingsItemSpacer()],
    [SettingsItemLogout()],
  ];

  static List<(SettingsItem, ListItemPosition)> get positionedItems => [
    for (final section in sections)
      for (final (index, item) in section.indexed)
        (item, ListItemPosition.fromIndex(index, length: section.length)),
  ];

  const SettingsItem();

  String get semanticsId;

  String title(BuildContext context);

  String subtitle(BuildContext context) => '';

  Color? titleColor(BuildContext context) => null;

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

final class SettingsItemSpacer extends SettingsItem {
  const SettingsItemSpacer();

  @override
  String get semanticsId => 'SettingsScreen.spacerItem';

  @override
  String title(BuildContext context) => '';

  @override
  void onTap(BuildContext context, SettingsScreenCoordinator coordinator) {}
}

final class SettingsItemLogout extends SettingsItem with DialogHelper {
  const SettingsItemLogout();

  @override
  String get semanticsId => 'SettingsScreen.logoutItem';

  @override
  String title(BuildContext context) => context.l10n.settingsItemLogout;

  @override
  String subtitle(BuildContext context) =>
      context.l10n.settingsItemLogoutDescription;

  @override
  Color? titleColor(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  @override
  void onTap(BuildContext context, SettingsScreenCoordinator coordinator) {
    unawaited(_confirmAndLogout(context, coordinator));
  }

  Future<void> _confirmAndLogout(
    BuildContext context,
    SettingsScreenCoordinator coordinator,
  ) async {
    final confirmed = await showConfirmation(
      context,
      isDestructive: true,
      title: context.commonL10n.commonAttention,
      message: context.l10n.settingsLogoutConfirmation,
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    await GetIt.I.get<AuthUsecase>().logout();
    if (context.mounted) {
      await coordinator.onLoggedOut(context);
    }
  }
}
