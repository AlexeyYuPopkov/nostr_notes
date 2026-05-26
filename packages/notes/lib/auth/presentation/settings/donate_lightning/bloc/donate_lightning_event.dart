import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/presentation/settings/donation_btc/open_wallet_helper.dart';
import '../tabs/donation_screen_tab.dart';

sealed class DonateLightningEvent extends Equatable {
  const DonateLightningEvent();

  const factory DonateLightningEvent.updateSats(int sats) = UpdateSatsEvent;
  const factory DonateLightningEvent.selectWallet(LightningApps? wallet) =
      SelectWalletEvent;
  const factory DonateLightningEvent.changeTab({
    required DonationScreenTab selectedTab,
  }) = ChangeTabEvent;
  const factory DonateLightningEvent.submit() = SubmitEvent;

  @override
  List<Object?> get props => [];
}

final class UpdateSatsEvent extends DonateLightningEvent {
  final int sats;
  const UpdateSatsEvent(this.sats);
}

final class SelectWalletEvent extends DonateLightningEvent {
  final LightningApps? wallet;
  const SelectWalletEvent(this.wallet);
}

final class ChangeTabEvent extends DonateLightningEvent {
  final DonationScreenTab selectedTab;
  const ChangeTabEvent({required this.selectedTab});

  @override
  List<Object?> get props => [selectedTab];
}

final class SubmitEvent extends DonateLightningEvent {
  const SubmitEvent();
}
