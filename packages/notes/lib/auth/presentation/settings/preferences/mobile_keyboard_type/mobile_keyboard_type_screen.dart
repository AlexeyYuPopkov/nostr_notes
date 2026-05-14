import 'package:common/presentation/tools/list_item_position.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:nostr_notes/auth/domain/repo/pin_keyboard_type_repo.dart';
import 'package:nostr_notes/common/domain/model/pin_keyboard_type.dart';

final class MobileKeyboardTypeScreen extends StatefulWidget {
  const MobileKeyboardTypeScreen({super.key});

  @override
  State<MobileKeyboardTypeScreen> createState() =>
      _MobileKeyboardTypeScreenState();
}

final class _MobileKeyboardTypeScreenState
    extends State<MobileKeyboardTypeScreen> {
  late final PinKeyboardTypeRepo _repo = DiStorage.shared.resolve();
  late PinKeyboardType _selected = _repo.getType();

  Future<void> _onChanged(PinKeyboardType type) async {
    setState(() => _selected = type);
    await _repo.saveType(type);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pinKeyboardTypeScreenTitle)),
      body: RadioGroup(
        groupValue: _selected,
        onChanged: (v) {
          if (v != null) {
            _onChanged(v);
          }
        },
        child: ListView.builder(
          itemCount: PinKeyboardType.values.length,
          itemBuilder: (context, index) {
            final item = PinKeyboardType.values[index];
            return SettingsItemTile(
              title: item.getSectionTitle(l10n),
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
      ),
    );
  }
}

extension on PinKeyboardType {
  String getSectionTitle(Localization l10n) {
    return switch (this) {
      PinKeyboardType.text => l10n.pinKeyboardTypeText,
      PinKeyboardType.number => l10n.pinKeyboardTypeNumber,
      PinKeyboardType.phone => l10n.pinKeyboardTypePhone,
    };
  }

  ListItemPosition get position {
    switch (this) {
      case PinKeyboardType.text:
        return .first;
      case PinKeyboardType.number:
        return .middle;
      case PinKeyboardType.phone:
        return .last;
    }
  }
}
