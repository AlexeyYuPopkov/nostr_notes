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

enum DonationPreset {
  preset100(100),
  preset500(500),
  preset1000(1000),
  preset5000(5000),
  preset10000(10000);

  final int amount;
  const DonationPreset(this.amount);

  static List<DonationPreset> get presets => const [
    DonationPreset.preset100,
    DonationPreset.preset500,
    DonationPreset.preset1000,
    DonationPreset.preset5000,
    DonationPreset.preset10000,
  ];

  @override
  String toString() => amount.toString();
}
