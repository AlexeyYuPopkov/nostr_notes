import 'package:common/domain/error/app_error.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/donate_lightning/bloc/donate_lightning_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/donate_lightning/bloc/donate_lightning_event.dart';
import 'package:nostr_notes/auth/presentation/settings/donate_lightning/bloc/donate_lightning_state.dart';
import 'package:nostr_notes/auth/presentation/settings/donation_btc/open_wallet_helper.dart';

final class DonateLightningScreen extends StatelessWidget with DialogHelper {
  const DonateLightningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DonateLightningBloc(),
      child: const _Body(),
    );
  }
}

final class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

final class _BodyState extends State<_Body> with DialogHelper {
  late final TextEditingController _controller;

  static const _presets = [100, 500, 1000, 5000, 10000];

  @override
  void initState() {
    super.initState();
    final initialSats = context.read<DonateLightningBloc>().data.sats;
    _controller = TextEditingController(text: initialSats.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _listener(BuildContext context, DonateLightningState state) {
    switch (state) {
      case InvoiceReadyState():
        OpenWalletHelper.openLightningInvoice(
          state.invoice,
          lightningApp: state.data.selectedWallet,
        );
      case ErrorState():
        final message =
            AppError.getMessageOrNull(state.e) ?? 'Failed to generate invoice';
        showError(context, error: AppError.common(message: message));
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DonateLightningBloc, DonateLightningState>(
      listener: _listener,
      builder: (context, state) {
        final isLoading = state is LoadingState;
        final data = state.data;

        return Scaffold(
          appBar: AppBar(title: const Text('Donate via Lightning ⚡')),
          body: AbsorbPointer(
            absorbing: isLoading,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 8),
                Text(
                  'Support development with a lightning payment',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // --- Sats input ---
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Amount (sats)',
                    border: OutlineInputBorder(),
                    suffixText: 'sats',
                  ),
                  onChanged: (v) {
                    final sats = int.tryParse(v) ?? 0;
                    context.read<DonateLightningBloc>().add(
                      DonateLightningEvent.updateSats(sats),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // --- Preset buttons ---
                Wrap(
                  spacing: 8,
                  children: _presets.map((amount) {
                    return ActionChip(
                      label: Text('$amount'),
                      onPressed: () {
                        _controller.text = amount.toString();
                        context.read<DonateLightningBloc>().add(
                          DonateLightningEvent.updateSats(amount),
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // --- Wallet picker ---
                Text(
                  'Open in wallet (optional)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: LightningApps.values.map((app) {
                    final selected = data.selectedWallet == app;
                    return FilterChip(
                      label: Text(app.displayName),
                      selected: selected,
                      onSelected: (_) {
                        context.read<DonateLightningBloc>().add(
                          DonateLightningEvent.selectWallet(app),
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // --- Submit ---
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  FilledButton.icon(
                    onPressed: data.sats > 0
                        ? () => context.read<DonateLightningBloc>().add(
                            const DonateLightningEvent.submit(),
                          )
                        : null,
                    icon: const Icon(Icons.bolt),
                    label: Text(
                      data.selectedWallet != null
                          ? 'Open in ${data.selectedWallet!.displayName}'
                          : 'Generate invoice',
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
