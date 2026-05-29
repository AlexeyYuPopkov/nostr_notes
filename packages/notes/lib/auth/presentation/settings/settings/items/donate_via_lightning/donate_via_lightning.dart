import 'dart:async';

import 'package:common/data/zap/fetch_lightning_donation_usecase.dart';
import 'package:common/data/zap/get_lightning_donation_usecase.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/items/donate_via_lightning/donate_via_lightning_vm.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class DonateViaLightning extends StatefulWidget {
  final DonateViaLightningVm? vm;

  const DonateViaLightning({super.key, this.vm});

  @override
  State<DonateViaLightning> createState() => _DonateViaLightningState();
}

final class _DonateViaLightningState extends State<DonateViaLightning> {
  late final _ownsVm = widget.vm == null;
  late final _vm =
      widget.vm ??
      DonateViaLightningVm(
        fetchLightningDonationUsecase: FetchLightningDonationUsecase(
          nostrClient: DiStorage.shared.resolve<NostrClient>(),
          eventStore: DiStorage.shared.resolve<RawEventStore>(),
        ),
        getLightningDonationUsecase: GetLightningDonationUsecase(
          eventStore: DiStorage.shared.resolve<RawEventStore>(),
        ),
      );

  @override
  void initState() {
    super.initState();
    _vm.subscribe();
  }

  @override
  void dispose() {
    if (_ownsVm) {
      unawaited(_vm.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _vm.invoice,
      builder: (context, sats, _) {
        final theme = Theme.of(context);
        final prefix = context.l10n.settingsItemDonateBTC;
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: prefix),
              if (sats > 0)
                TextSpan(
                  text: '$sats sats',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
