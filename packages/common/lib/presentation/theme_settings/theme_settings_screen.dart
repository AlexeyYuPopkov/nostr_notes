import 'package:common/app/theme/app_background_colors.dart';
import 'package:common/app/vm/global_settings_scope.dart';
import 'package:common/l10n/localization.dart';
import 'package:common/presentation/tools/section_scroll_vm.dart';
import 'package:flutter/material.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:common/presentation/tools/list_item_position.dart';
import 'package:common/app/theme/sizes.dart';

final class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen>
    with DialogHelper, _OnThemeChanged {
  final scrollController = ScrollController();
  late final _scrollVm = SectionScrollVm<_Section>(
    scrollController: scrollController,
  );
  late final _vm = GlobalSettingsScope.of(context);

  @override
  void dispose() {
    _scrollVm.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.commonL10n;

    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder(
          valueListenable: _scrollVm.currentItemNotifier,
          builder: (context, value, child) {
            return Text(
              value == null
                  ? l10n.themeScreenTitle
                  : value.getSectionTitle(l10n),
            );
          },
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: _vm.themeModeNotifier,
        builder: (context, themeMode, child) {
          return RadioGroup(
            groupValue: themeMode,
            onChanged: (mode) => onChanged(context, mode: mode),
            child: ListView(
              controller: _scrollVm.scrollController,
              // physics: AlwaysScrollableScrollPhysics(),
              children: [
                SectionTitle(
                  sectionTitle: l10n.themeScreenSectionTitleColorTheme,
                  onChangeDependencies: (ctx) =>
                      _scrollVm.registerSection(.colorTheme, ctx),
                ),
                const _Tile(
                  themeMode: ThemeMode.system,
                  position: ListItemPosition.first,
                ),
                const _Tile(
                  themeMode: ThemeMode.light,
                  position: ListItemPosition.middle,
                ),
                const _Tile(
                  themeMode: ThemeMode.dark,
                  position: ListItemPosition.last,
                ),
                _ColorPicker(
                  brightness: .light,
                  colors: AppBackgroundColors.light,
                  title: l10n.themeScreenLabelBackground,
                  position: ListItemPosition.first,
                  notifier: _vm.lightBgIndexNotifier,
                  onChanged: _vm.setLightBgIndex,
                  onBuildSectionTitle: (ctx) =>
                      _scrollVm.registerSection(.colorsLight, ctx),
                ),
                _ColorPicker(
                  brightness: .light,
                  colors: AppBackgroundColors.lightCard,
                  title: l10n.themeScreenLabelCards,
                  position: ListItemPosition.last,
                  notifier: _vm.lightCardIndexNotifier,
                  onChanged: _vm.setLightCardIndex,
                ),
                _ColorPicker(
                  brightness: .dark,
                  colors: AppBackgroundColors.dark,
                  title: l10n.themeScreenLabelBackground,
                  position: ListItemPosition.first,
                  notifier: _vm.darkBgIndexNotifier,
                  onChanged: _vm.setDarkBgIndex,
                  onBuildSectionTitle: (ctx) =>
                      _scrollVm.registerSection(.colorsDark, ctx),
                ),
                _ColorPicker(
                  brightness: .dark,
                  colors: AppBackgroundColors.darkCard,
                  title: l10n.themeScreenLabelCards,
                  position: ListItemPosition.last,
                  notifier: _vm.darkCardIndexNotifier,
                  onChanged: _vm.setDarkCardIndex,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

enum _Section {
  colorTheme,
  colorsLight,
  colorsDark;

  String getSectionTitle(CommonL10n l10n) {
    switch (this) {
      case .colorTheme:
        return l10n.themeScreenSectionTitleColorTheme;
      case .colorsLight:
        return l10n.themeScreenLabelLight;
      case .colorsDark:
        return l10n.themeScreenLabelDark;
    }
  }
}

final class _Tile extends StatelessWidget with _OnThemeChanged {
  final ThemeMode themeMode;
  final ListItemPosition position;

  const _Tile({required this.themeMode, required this.position});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SettingsItemTile(
      title: themeMode.getName(context),
      position: position,
      trailing: Radio.adaptive(
        value: themeMode,
        activeColor: theme.colorScheme.primary,
      ),
      onTap: () => onChanged(context, mode: themeMode),
    );
  }
}

final class _ColorPicker extends StatelessWidget {
  final Brightness brightness;
  final List<Color> colors;
  final String title;
  final ListItemPosition position;
  final ValueNotifier<int> notifier;
  final ValueChanged<int> onChanged;
  final void Function(BuildContext)? onBuildSectionTitle;

  const _ColorPicker({
    required this.brightness,
    required this.colors,
    required this.title,
    required this.position,
    required this.notifier,
    required this.onChanged,
    this.onBuildSectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, selectedIndex, _) {
        return SettingsItemTile(
          title: title,
          position: position,
          sectionTitle: _getSectionTitle(context),
          trailing: _ColorSwatchRow(
            colors: colors,
            selectedIndex: selectedIndex,
            onSelected: onChanged,
          ),
          onTap: null,
          onBuildSectionTitle: onBuildSectionTitle,
        );
      },
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
            width: Sizes.indentVariant4x,
            height: Sizes.indentVariant4x,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                width: isSelected ? Sizes.thickness2x : Sizes.thickness,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    size: Sizes.iconSmall,
                    color: theme.colorScheme.primary,
                  )
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
