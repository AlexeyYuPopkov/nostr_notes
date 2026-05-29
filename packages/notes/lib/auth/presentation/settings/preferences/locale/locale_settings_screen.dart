import 'package:common/app/vm/global_settings_scope.dart';
import 'package:common/presentation/tools/list_item_position.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class LocaleSettingsScreen extends StatefulWidget {
  const LocaleSettingsScreen({super.key});

  @override
  State<LocaleSettingsScreen> createState() => _LocaleSettingsScreenState();
}

final class _LocaleSettingsScreenState extends State<LocaleSettingsScreen> {
  Future<void> _onChanged(_LocaleOption option) async {
    final vm = GlobalSettingsScope.of(context);
    await vm.setLocale(option.locale);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final vm = GlobalSettingsScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.preferencesScreenItemLanguage)),
      body: ValueListenableBuilder<Locale?>(
        valueListenable: vm.localeNotifier,
        builder: (context, selectedLocale, _) {
          final selected = _LocaleOption.fromLocale(selectedLocale);

          return RadioGroup<_LocaleOption>(
            groupValue: selected,
            onChanged: (value) {
              if (value != null) {
                _onChanged(value);
              }
            },
            child: ListView.builder(
              itemCount: _LocaleOption.values.length,
              itemBuilder: (context, index) {
                final item = _LocaleOption.values[index];
                return SettingsItemTile(
                  title: Text(item.getTitle(l10n)),
                  position: item.position,
                  sectionTitle: '',
                  trailing: Radio.adaptive(
                    value: item,
                    activeColor: theme.colorScheme.primary,
                  ),
                  onTap: () => _onChanged(item),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

enum _LocaleOption {
  system,
  english,
  russian;

  Locale? get locale => switch (this) {
    _LocaleOption.system => null,
    _LocaleOption.english => const Locale('en'),
    _LocaleOption.russian => const Locale('ru'),
  };

  static _LocaleOption fromLocale(Locale? locale) {
    final code = locale?.languageCode;
    return switch (code) {
      'en' => _LocaleOption.english,
      'ru' => _LocaleOption.russian,
      _ => _LocaleOption.system,
    };
  }
}

extension on _LocaleOption {
  String getTitle(Localization l10n) {
    return switch (this) {
      _LocaleOption.system => l10n.preferencesScreenLanguageSystem,
      _LocaleOption.english => l10n.preferencesScreenLanguageEnglish,
      _LocaleOption.russian => l10n.preferencesScreenLanguageRussian,
    };
  }

  ListItemPosition get position {
    return switch (this) {
      _LocaleOption.system => .first,
      _LocaleOption.english => .middle,
      _LocaleOption.russian => .last,
    };
  }
}
