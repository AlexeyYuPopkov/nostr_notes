import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pinKeyboardTypeScreenTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.indent2x,
            vertical: Sizes.indent,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: Sizes.indent,
                bottom: Sizes.indent2x,
              ),
              child: Text(
                l10n.pinKeyboardTypeScreenDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            RadioGroup<PinKeyboardType>(
              groupValue: _selected,
              onChanged: (value) {
                if (value != null) _onChanged(value);
              },
              child: Column(
                children: [
                  for (final type in PinKeyboardType.values)
                    RadioListTile<PinKeyboardType>(
                      title: Text(_titleForType(l10n, type)),
                      value: type,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _titleForType(Localization l10n, PinKeyboardType type) {
    return switch (type) {
      PinKeyboardType.text => l10n.pinKeyboardTypeText,
      PinKeyboardType.number => l10n.pinKeyboardTypeNumber,
      PinKeyboardType.phone => l10n.pinKeyboardTypePhone,
    };
  }
}
