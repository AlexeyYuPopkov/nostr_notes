import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/buttons/prymary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/donate_lightning/bloc/donate_lightning_bloc.dart';
import 'package:nostr_notes/l10n/localization.dart';

import '../bloc/donate_lightning_data.dart';
import '../bloc/donate_lightning_event.dart';
import '../bloc/donate_lightning_state.dart';

final class DonationScreenAmountTab extends StatelessWidget {
  static const _inputHintSuffix = 'sats';
  static List<DonationPreset> get _presets => DonationPreset.presets;

  const DonationScreenAmountTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return BlocBuilder<DonateLightningBloc, DonateLightningState>(
      builder: (context, state) {
        final bloc = context.read<DonateLightningBloc>();
        final isLoading = state is LoadingState;
        final data = state.data;

        return AbsorbPointer(
          absorbing: isLoading,
          child: ListView(
            padding: const EdgeInsets.all(Sizes.indent2x),
            children: [
              const SizedBox(height: Sizes.indent),
              Text(
                l10n.donateLightningScreenSubtitle,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: Sizes.indentVariant4x),

              // --- Sats input ---
              TextField(
                controller: bloc.controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.donateLightningScreenInputHint,
                  border: const OutlineInputBorder(),
                  suffixText: _inputHintSuffix,
                ),
                onChanged: (str) {
                  final sats = int.tryParse(str) ?? 0;
                  bloc.add(DonateLightningEvent.updateSats(sats));
                },
              ),
              const SizedBox(height: Sizes.indentVariant2x),

              _PresetButtons(data: data),
              const SizedBox(height: Sizes.indent4x),

              Align(
                alignment: Alignment.center,
                child: PrymaryLoadingButton(
                  vm: bloc.buttonVM,
                  title: l10n.donateLightningScreenSubmitButtonGenerateInvoice,
                  onTap: data.sats > 0
                      ? () => bloc.add(const DonateLightningEvent.submit())
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

final class _PresetButtons extends StatelessWidget {
  final DonateLightningData data;
  const _PresetButtons({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: Sizes.indent,
      children: [
        for (final amount in DonationScreenAmountTab._presets)
          ActionChip(
            label: Text(
              '${amount.amount}',
              style: TextStyle(
                color: data.sats == amount.amount
                    ? theme.colorScheme.onPrimary
                    : null,
              ),
            ),
            color: data.sats == amount.amount
                ? .all(theme.colorScheme.primary)
                : null,
            onPressed: () => _onPresetTap(context, amount.amount),
          ),
      ],
    );
  }

  void _onPresetTap(BuildContext context, int amount) {
    final bloc = context.read<DonateLightningBloc>();
    bloc.controller.text = amount.toString();
    bloc.add(DonateLightningEvent.updateSats(amount));
  }
}
