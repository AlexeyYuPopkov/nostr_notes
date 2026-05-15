import 'package:nostr_notes/auth/presentation/settings/donation_btc/open_wallet_helper.dart';

sealed class DonateLightningEvent {
  const DonateLightningEvent();

  const factory DonateLightningEvent.updateSats(int sats) = UpdateSatsEvent;
  const factory DonateLightningEvent.selectWallet(LightningApps? wallet) =
      SelectWalletEvent;
  const factory DonateLightningEvent.submit() = SubmitEvent;
}

final class UpdateSatsEvent extends DonateLightningEvent {
  final int sats;
  const UpdateSatsEvent(this.sats);
}

final class SelectWalletEvent extends DonateLightningEvent {
  final LightningApps? wallet;
  const SelectWalletEvent(this.wallet);
}

final class SubmitEvent extends DonateLightningEvent {
  const SubmitEvent();
}
