import 'package:common/app/vm/global_settings_scope.dart';
import 'package:common/presentation/theme_settings/global_settings_vm.dart';
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
  Future<void> _onChanged(LanguageCode option) async {
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
          final selected = selectedLocale?.code ?? LanguageCode.system;

          return RadioGroup<LanguageCode>(
            groupValue: selected,
            onChanged: (value) {
              if (value != null) {
                _onChanged(value);
              }
            },
            child: ListView.builder(
              itemCount: LanguageCode.values.length,
              itemBuilder: (context, index) {
                final item = LanguageCode.values[index];
                return SettingsItemTile(
                  title: Text(item.getLocalizedName(l10n)),
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

extension on LanguageCode {
  ListItemPosition get position {
    return switch (this) {
      LanguageCode.system => .first,
      LanguageCode.en => .middle,
      LanguageCode.ru => .middle,
      LanguageCode.bg => .last,
    };
  }
}


