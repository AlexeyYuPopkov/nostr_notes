import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/presentation/settings/donation_btc/open_wallet_helper.dart';

final class DonateLightningData extends Equatable {
  final int sats;
  final LightningApps? selectedWallet;

  const DonateLightningData({this.sats = 1000, this.selectedWallet});

  DonateLightningData copyWith({int? sats, LightningApps? Function()? wallet}) {
    return DonateLightningData(
      sats: sats ?? this.sats,
      selectedWallet: wallet != null ? wallet() : selectedWallet,
    );
  }

  @override
  List<Object?> get props => [sats, selectedWallet];
}
