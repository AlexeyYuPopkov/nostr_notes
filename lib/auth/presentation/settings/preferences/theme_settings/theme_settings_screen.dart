import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/presentation/global_settings/bloc/global_settings_bloc.dart';
import 'package:nostr_notes/app/presentation/global_settings/bloc/global_settings_event.dart';
import 'package:nostr_notes/app/presentation/global_settings/bloc/global_settings_state.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';
import 'package:nostr_notes/common/presentation/tools/list_item_position.dart';

final class ThemeSettingsScreen extends StatelessWidget
    with DialogHelper, _OnThemeChanged {
  const ThemeSettingsScreen({super.key});

  void _listener(BuildContext context, GlobalSettingsState state) {
    switch (state) {
      case CommonState():
      case LoadingState():
        break;
      case ErrorState():
        showError(context, error: state.e);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider.value(
      value: context.read<GlobalSettingsBloc>(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.themeScreenTitle)),
        body: BlocConsumer<GlobalSettingsBloc, GlobalSettingsState>(
          listener: _listener,
          builder: (context, state) {
            final currentTheme = state.data.themeMode;
            return AbsorbPointer(
              absorbing: state is LoadingState,
              child: RadioGroup(
                groupValue: currentTheme,
                onChanged: (mode) => onChanged(context, mode: mode),
                child: ListView(
                  children: [
                    _Tile(
                      themeMode: ThemeMode.system,
                      currentTheme: currentTheme,
                      position: ListItemPosition.first,
                    ),
                    _Tile(
                      themeMode: ThemeMode.light,
                      currentTheme: currentTheme,
                      position: ListItemPosition.middle,
                    ),
                    _Tile(
                      themeMode: ThemeMode.dark,
                      currentTheme: currentTheme,
                      position: ListItemPosition.last,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

final class _Tile extends StatelessWidget with _OnThemeChanged {
  final ThemeMode themeMode;
  final ThemeMode currentTheme;
  final ListItemPosition position;

  const _Tile({
    required this.themeMode,
    required this.currentTheme,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isSelected = themeMode == currentTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.indent2x),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.outline
              : theme.colorScheme.outlineVariant,
          borderRadius: position.getRadius(),
          border: position.getBorder(
            theme.colorScheme.outline,
            thickness: Sizes.thicknessHalf,
          ),
        ),
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.indent2x),
          onPressed: () => onChanged(context, mode: themeMode),
          child: Row(
            spacing: Sizes.indent2x,
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                themeMode.getName(context),
                style: theme.textTheme.titleSmall,
              ),
              Radio.adaptive(
                value: themeMode,
                activeColor: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

mixin _OnThemeChanged {
  void onChanged(BuildContext context, {required ThemeMode? mode}) {
    if (mode != null) {
      context.read<GlobalSettingsBloc>().add(
        GlobalSettingsEvent.themeChanged(mode: mode),
      );
    }
  }
}

extension on ThemeMode {
  String getName(BuildContext context) {
    switch (this) {
      case ThemeMode.system:
        return context.l10n.themeScreenLabelSystem;
      case ThemeMode.light:
        return context.l10n.themeScreenLabelLight;
      case ThemeMode.dark:
        return context.l10n.themeScreenLabelDark;
    }
  }
}
