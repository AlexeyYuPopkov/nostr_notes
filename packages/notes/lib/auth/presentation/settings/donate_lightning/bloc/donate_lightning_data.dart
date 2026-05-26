import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/presentation/settings/donate_lightning/tabs/donation_screen_tab.dart';
import 'package:nostr_notes/auth/presentation/settings/donation_btc/open_wallet_helper.dart';

final class DonateLightningData extends Equatable {
  final int sats;
  final DonationScreenTab selectedTab;
  final LightningApps? selectedWallet;
  final String invoice;

  const DonateLightningData._({
    required this.sats,
    required this.selectedWallet,
    required this.selectedTab,
    required this.invoice,
  });

  factory DonateLightningData.initial() {
    return const DonateLightningData._(
      sats: 1000,
      selectedWallet: null,
      selectedTab: DonationScreenTab.amount(),
      invoice: '',
    );
  }

  DonateLightningData copyWith({
    int? sats,
    DonationScreenTab? selectedTab,
    LightningApps? Function()? wallet,
    String? invoice,
  }) {
    return DonateLightningData._(
      sats: sats ?? this.sats,
      selectedTab: selectedTab ?? this.selectedTab,
      selectedWallet: wallet != null ? wallet() : selectedWallet,
      invoice: invoice ?? this.invoice,
    );
  }

  @override
  List<Object?> get props => [sats, selectedTab, selectedWallet, invoice];
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
