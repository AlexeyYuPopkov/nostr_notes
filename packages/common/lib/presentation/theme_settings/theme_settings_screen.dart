import 'package:common/app/theme/app_background_colors.dart';
import 'package:common/app/vm/global_settings_scope.dart';
import 'package:common/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:common/presentation/tools/list_item_position.dart';
import 'package:common/app/theme/sizes.dart';

final class ThemeSettingsScreen extends StatelessWidget
    with DialogHelper, _OnThemeChanged {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.commonL10n;
    final vm = GlobalSettingsScope.of(context);
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: vm.themeModeNotifier,
        builder: (context, themeMode, child) {
          return RadioGroup(
            groupValue: themeMode,
            onChanged: (mode) => onChanged(context, mode: mode),
            child: CustomScrollView(
              slivers: [
                SliverAppBar.medium(
                  title: Text(l10n.themeScreenTitle),
                  toolbarHeight: Sizes.appBarHeight,
                ),
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
                _SliverColorPicker(
                  brightness: .light,
                  colors: AppBackgroundColors.light,
                  title: l10n.themeScreenLabelBackground,
                  notifier: vm.lightBgIndexNotifier,
                  onChanged: vm.setLightBgIndex,
                ),
                _SliverColorPicker(
                  brightness: .dark,
                  colors: AppBackgroundColors.dark,
                  title: l10n.themeScreenLabelBackground,
                  notifier: vm.darkBgIndexNotifier,
                  onChanged: vm.setDarkBgIndex,
                ),
                _SliverColorPicker(
                  brightness: .light,
                  colors: AppBackgroundColors.lightCard,
                  title: l10n.themeScreenLabelCards,
                  notifier: vm.lightCardIndexNotifier,
                  onChanged: vm.setLightCardIndex,
                ),
                _SliverColorPicker(
                  brightness: .dark,
                  colors: AppBackgroundColors.darkCard,
                  title: l10n.themeScreenLabelCards,
                  notifier: vm.darkCardIndexNotifier,
                  onChanged: vm.setDarkCardIndex,
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

final class _SliverColorPicker extends StatelessWidget {
  final Brightness brightness;
  final List<Color> colors;
  final String title;
  final ValueNotifier<int> notifier;
  final ValueChanged<int> onChanged;

  const _SliverColorPicker({
    required this.brightness,
    required this.colors,
    required this.title,
    required this.notifier,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = brightness == theme.brightness;
    return SliverToBoxAdapter(
      child: AbsorbPointer(
        absorbing: !isEnabled,
        child: Opacity(
          opacity: isEnabled ? 1 : 0.7,
          child: ValueListenableBuilder(
            valueListenable: notifier,
            builder: (context, selectedIndex, _) {
              return SettingsItemTile(
                title: title,
                position: ListItemPosition.single,
                sectionTitle: _getSectionTitle(context),
                trailing: _ColorSwatchRow(
                  colors: colors,
                  selectedIndex: selectedIndex,
                  onSelected: onChanged,
                ),
                onTap: null,
              );
            },
          ),
        ),
      ),
    );
  }

  String _getSectionTitle(BuildContext context) => switch (brightness) {
    .light => context.commonL10n.themeScreenLabelLight,
    .dark => context.commonL10n.themeScreenLabelDark,
  };
}

final class _ColorSwatchRow extends StatelessWidget {
  final List<Color> colors;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _ColorSwatchRow({
    required this.colors,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Sizes.indent,
      children: List.generate(colors.length, (i) {
        final color = colors[i];
        final isSelected = i == selectedIndex;
        return GestureDetector(
          onTap: () => onSelected(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                width: isSelected ? 2.5 : 1,
              ),
            ),
            child: isSelected
                ? Icon(Icons.check, size: 18, color: theme.colorScheme.primary)
                : null,
          ),
        );
      }),
    );
  }
}

mixin _OnThemeChanged {
  void onChanged(BuildContext context, {required ThemeMode? mode}) {
    if (mode != null) {
      GlobalSettingsScope.of(context).setThemeMode(mode);
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
