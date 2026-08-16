import 'package:common/app/theme/app_theme_style.dart';
import 'package:common/app/vm/global_settings_scope.dart';
import 'package:common/l10n/localization.dart';
import 'package:common/presentation/tools/section_scroll_vm.dart';
import 'package:flutter/material.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';

import 'package:common/presentation/tools/list_item_position.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';

import 'widgets/theme_style_icon.dart';

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
                _StylePicker(
                  brightness: .light,
                  title: l10n.themeScreenLabelStyle,
                  sectionTitle: l10n.themeScreenLabelLight,
                  notifier: _vm.lightThemeStyleNotifier,
                  onChanged: _vm.setLightThemeStyle,
                  onBuildSectionTitle: (ctx) =>
                      _scrollVm.registerSection(.colorsLight, ctx),
                ),
                _StylePicker(
                  brightness: .dark,
                  title: l10n.themeScreenLabelStyle,
                  sectionTitle: l10n.themeScreenLabelDark,
                  notifier: _vm.darkThemeStyleNotifier,
                  onChanged: _vm.setDarkThemeStyle,
                  onBuildSectionTitle: (ctx) =>
                      _scrollVm.registerSection(.colorsDark, ctx),
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
      title: Text(themeMode.getName(context)),
      position: position,
      trailing: Radio.adaptive(
        value: themeMode,
        activeColor: theme.colorScheme.primary,
      ),
      onTap: () => onChanged(context, mode: themeMode),
    );
  }
}

/// One brightness's independently-selectable [AppThemeStyle] — three named
/// tiles (Default / Apple Notes / Claude), each previewing its own
/// background+primary rather than a bare color dot, since a style is more
/// than a single swatch now.
final class _StylePicker extends StatelessWidget {
  final Brightness brightness;
  final String title;
  final String sectionTitle;
  final ValueNotifier<AppThemeStyle> notifier;
  final ValueChanged<AppThemeStyle> onChanged;
  final void Function(BuildContext)? onBuildSectionTitle;

  const _StylePicker({
    required this.brightness,
    required this.title,
    required this.sectionTitle,
    required this.notifier,
    required this.onChanged,
    this.onBuildSectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, selected, _) {
        final styles = AppThemeStyle.values;
        return RadioGroup<AppThemeStyle>(
          groupValue: selected,
          onChanged: (style) {
            if (style != null) onChanged(style);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (i, style) in styles.indexed)
                _StyleTile(
                  style: style,
                  brightness: brightness,
                  position: ListItemPosition.fromIndex(
                    i,
                    length: styles.length,
                  ),
                  sectionTitle: i == 0 ? sectionTitle : '',
                  onBuildSectionTitle: i == 0 ? onBuildSectionTitle : null,
                  onTap: () => onChanged(style),
                ),
            ],
          ),
        );
      },
    );
  }
}

final class _StyleTile extends StatelessWidget {
  final AppThemeStyle style;
  final Brightness brightness;
  final ListItemPosition position;
  final String sectionTitle;
  final void Function(BuildContext)? onBuildSectionTitle;
  final VoidCallback onTap;

  const _StyleTile({
    required this.style,
    required this.brightness,
    required this.position,
    required this.sectionTitle,
    required this.onBuildSectionTitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = style.paletteFor(brightness);

    return SettingsItemTile(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThemeStyleIcon(palette: palette),
          const SizedBox(width: Sizes.indent2x),
          Text(style.getLocalizedName(context)),
        ],
      ),
      position: position,
      sectionTitle: sectionTitle,
      trailing: Radio<AppThemeStyle>.adaptive(
        value: style,
        activeColor: theme.colorScheme.primary,
      ),
      onTap: onTap,
      onBuildSectionTitle: onBuildSectionTitle,
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
