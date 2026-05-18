import 'package:common/app/theme/sizes.dart';
import 'package:common/domain/error/app_error.dart';
import 'package:common/presentation/buttons/prymary_button.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/donate_lightning/bloc/donate_lightning_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/donate_lightning/bloc/donate_lightning_event.dart';
import 'package:nostr_notes/auth/presentation/settings/donate_lightning/bloc/donate_lightning_state.dart';
import 'package:nostr_notes/auth/presentation/settings/donation_btc/open_wallet_helper.dart';
import 'package:nostr_notes/l10n/localization.dart';

import 'bloc/donate_lightning_data.dart';

final class DonateLightningScreen extends StatelessWidget {
  const DonateLightningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DonateLightningBloc(),
      child: const _Body(),
    );
  }
}

final class _Body extends StatelessWidget with DialogHelper {
  static const donateLightningScreenInputHintSuffix = 'sats';
  const _Body();

  static List<DonationPreset> get _presets => DonationPreset.presets;

  void _listener(BuildContext context, DonateLightningState state) {
    switch (state) {
      case InvoiceReadyState():
        OpenWalletHelper.openLightningInvoice(
          state.invoice,
          lightningApp: state.data.selectedWallet,
        );
      case ErrorState():
        final message =
            AppError.getMessageOrNull(state.e) ??
            context.l10n.donateLightningScreenErrorInvoice;
        showError(context, error: AppError.common(message: message));
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return BlocConsumer<DonateLightningBloc, DonateLightningState>(
      listener: _listener,
      builder: (context, state) {
        final bloc = context.read<DonateLightningBloc>();
        final isLoading = state is LoadingState;
        final data = state.data;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.donateLightningScreenTitle)),
          body: AbsorbPointer(
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
                    border: OutlineInputBorder(),
                    suffixText: donateLightningScreenInputHintSuffix,
                  ),
                  onChanged: (str) => _onTextChanged(context, str),
                ),
                const SizedBox(height: Sizes.indentVariant2x),

                // --- Preset buttons ---
                Wrap(
                  spacing: Sizes.indent,
                  children: [
                    for (final amount in _presets)
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

                        onPressed: () => _onPresetPressed(context, amount),
                      ),
                  ],
                ),
                const SizedBox(height: Sizes.indent4x),

                // --- Wallet picker ---
                Text(
                  l10n.donateLightningScreenWalletSectionTitle,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: Sizes.indent),
                Wrap(
                  spacing: Sizes.indent,
                  runSpacing: Sizes.halfIndent,
                  children: LightningApps.values.map((app) {
                    final selected = data.selectedWallet == app;
                    return FilterChip(
                      label: Text(app.displayName),
                      selected: selected,
                      onSelected: (_) => _onSelectWallet(context, app),
                    );
                  }).toList(),
                ),
                const SizedBox(height: Sizes.indent4x),

                PrymaryLoadingButton(
                  vm: bloc.buttonVM,
                  width: double.infinity,
                  title: data.selectedWallet != null
                      ? l10n.donateLightningScreenSubmitButtonOpenInWallet(
                          data.selectedWallet!.displayName,
                        )
                      : l10n.donateLightningScreenSubmitButtonGenerateInvoice,
                  onTap: data.sats > 0 ? () => _onSubmit(context) : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onTextChanged(BuildContext context, String str) {
    final sats = int.tryParse(str) ?? 0;
    final bloc = context.read<DonateLightningBloc>();
    bloc.add(DonateLightningEvent.updateSats(sats));
  }

  void _onPresetPressed(BuildContext context, DonationPreset preset) {
    final bloc = context.read<DonateLightningBloc>();
    bloc.controller.text = preset.toString();
    bloc.add(DonateLightningEvent.updateSats(preset.amount));
  }

  void _onSelectWallet(BuildContext context, LightningApps app) {
    final bloc = context.read<DonateLightningBloc>();
    bloc.add(DonateLightningEvent.selectWallet(app));
  }

  void _onSubmit(BuildContext context) {
    final bloc = context.read<DonateLightningBloc>();
    bloc.add(const DonateLightningEvent.submit());
  }
}
