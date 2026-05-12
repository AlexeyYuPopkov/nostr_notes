import 'package:common/app/vm/global_settings_scope.dart';
import 'package:common/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:common/presentation/tools/list_item_position.dart';

final class ThemeSettingsScreen extends StatelessWidget
    with DialogHelper, _OnThemeChanged {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.commonL10n;
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: GlobalSettingsScope.of(context).themeModeNotifier,
        builder: (context, themeMode, child) {
          return RadioGroup(
            groupValue: themeMode,
            onChanged: (mode) => onChanged(context, mode: mode),
            child: CustomScrollView(
              slivers: [
                SliverAppBar.medium(title: Text(l10n.themeScreenTitle)),
                const _SliverTile(
                  themeMode: ThemeMode.system,
                  position: ListItemPosition.first,
                ),
                const _SliverTile(
                  themeMode: ThemeMode.light,
                  position: ListItemPosition.middle,
                ),
                const _SliverTile(
                  themeMode: ThemeMode.dark,
                  position: ListItemPosition.last,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

final class _SliverTile extends StatelessWidget with _OnThemeChanged {
  final ThemeMode themeMode;
  final ListItemPosition position;

  const _SliverTile({required this.themeMode, required this.position});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: SettingsItemTile(
        title: themeMode.getName(context),
        position: position,
        trailing: Radio.adaptive(
          value: themeMode,
          activeColor: theme.colorScheme.primary,
        ),
        onTap: () => onChanged(context, mode: themeMode),
      ),
    );
  }
}

mixin _OnThemeChanged {
  void onChanged(BuildContext context, {required ThemeMode? mode}) {
    if (mode != null) {
      GlobalSettingsScope.of(context).themeMode = mode;
    }
  }
}

extension on ThemeMode {
  String getName(BuildContext context) {
    switch (this) {
      case ThemeMode.system:
        return context.commonL10n.themeScreenLabelSystem;
      case ThemeMode.light:
        return context.commonL10n.themeScreenLabelLight;
      case ThemeMode.dark:
        return context.commonL10n.themeScreenLabelDark;
    }
  }
}
