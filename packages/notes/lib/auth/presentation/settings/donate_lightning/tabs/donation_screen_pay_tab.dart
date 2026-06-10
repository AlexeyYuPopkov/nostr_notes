import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/buttons/prymary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:common/l10n/localization.dart';
import 'package:nostr_notes/auth/presentation/settings/donation_btc/open_wallet_helper.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../bloc/donate_lightning_bloc.dart';
import '../bloc/donate_lightning_event.dart';
import '../bloc/donate_lightning_state.dart';
import 'donation_screen_tab.dart';

final class DonationScreenPayTab extends StatelessWidget {
  const DonationScreenPayTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PayWebDesktopContent();
  }
}

final class _ButtonBack extends StatelessWidget {
  const _ButtonBack();

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      sizeStyle: .small,
      child: Text(
        context.l10n.donateLightningScreenButtonEditAmount,
        style: const TextStyle(fontSize: TextSizes.normal),
      ),
      onPressed: () => _onAmountTab(context),
    );
  }

  void _onAmountTab(BuildContext context) {
    context.read<DonateLightningBloc>().add(
      const DonateLightningEvent.changeTab(
        selectedTab: DonationScreenTab.amount(),
      ),
    );
  }
}

final class _ButtonDone extends StatelessWidget {
  const _ButtonDone();

  @override
  Widget build(BuildContext context) {
    return PrymaryButton(
      title: context.commonL10n.commonButtonDone,
      onTap: () => Navigator.of(context).pop(),
    );
  }
}

final class _PayWebDesktopContent extends StatelessWidget {
  const _PayWebDesktopContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Sizes.indent2x),
      children: [
        const SizedBox(height: Sizes.indent2x),
        const _Summary(),
        const SizedBox(height: Sizes.indent4x),
        const _Qr(),
        if (!OpenWalletHelper.isWebOrDesktop) ...[
          const SizedBox(height: Sizes.indent2x),
          const Align(alignment: Alignment.center, child: _OpenWithLightning()),
        ],
        const SizedBox(height: Sizes.indent4x),
        const Align(alignment: Alignment.center, child: _ButtonDone()),
        const SizedBox(height: Sizes.indent2x),
        const Align(alignment: Alignment.center, child: _ButtonBack()),
        const SizedBox(height: Sizes.indent4x),
      ],
    );
  }
}

final class _OpenWithLightning extends StatelessWidget {
  const _OpenWithLightning();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DonateLightningBloc, DonateLightningState, String>(
      selector: (state) => state.data.invoice,
      builder: (context, invoice) {
        if (invoice.isEmpty) return const SizedBox.shrink();

        return PrymaryButton(
          title: context.l10n.donateLightningScreenButtonOpenWithLightning,
          onTap: () async {
            final opened = await OpenWalletHelper.openLightningInvoice(
              lightningInvoice: invoice,
            );
            if (context.mounted && !opened) {
              final msg = context.l10n.donateLightningScreenQrInstruction;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(msg)));
            }
          },
        );
      },
    );
  }
}

final class _Summary extends StatelessWidget {
  const _Summary();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const suffix = 'sats';
    return Row(
      children: [
        Icon(Icons.bolt, color: theme.colorScheme.primary),
        const SizedBox(width: Sizes.halfIndent),
        BlocSelector<DonateLightningBloc, DonateLightningState, int>(
          selector: (state) {
            return state.data.sats;
          },
          builder: (context, sats) {
            return Text(
              '$sats $suffix',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            );
          },
        ),
      ],
    );
  }
}

final class _Qr extends StatelessWidget {
  const _Qr();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocSelector<DonateLightningBloc, DonateLightningState, String>(
      selector: (state) => state.data.invoice,
      builder: (context, invoice) {
        final l10n = context.l10n;
        return Column(
          spacing: Sizes.indent2x,
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Sizes.indent),
                ),
                child: QrImageView(data: 'lightning:$invoice', size: 300),
              ),
            ),
            Text(
              l10n.donateLightningScreenQrInstruction,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            Center(
              child: OpacityOutlinedButton(
                onTap: () => _onCopyInvoice(context, invoice),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Sizes.indent,
                  children: [
                    const Icon(Icons.copy, size: Sizes.iconSmall),
                    Text(l10n.donateLightningScreenButtonCopyInvoice),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onCopyInvoice(BuildContext context, String invoice) async {
    await Clipboard.setData(ClipboardData(text: invoice));
    if (context.mounted) {
      final msg = context.l10n.donateLightningScreenMessageInvoiceCopied;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }
}
