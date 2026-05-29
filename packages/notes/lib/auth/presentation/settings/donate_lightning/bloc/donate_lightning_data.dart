import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/presentation/settings/donate_lightning/tabs/donation_screen_tab.dart';

final class DonateLightningData extends Equatable {
  final int sats;
  final DonationScreenTab selectedTab;
  final String invoice;

  const DonateLightningData._({
    required this.sats,
    required this.selectedTab,
    required this.invoice,
  });

  factory DonateLightningData.initial() {
    return const DonateLightningData._(
      sats: 1000,
      selectedTab: DonationScreenTab.amount(),
      invoice: '',
    );
  }

  DonateLightningData copyWith({
    int? sats,
    DonationScreenTab? selectedTab,
    String? invoice,
  }) {
    return DonateLightningData._(
      sats: sats ?? this.sats,
      selectedTab: selectedTab ?? this.selectedTab,
      invoice: invoice ?? this.invoice,
    );
  }

  @override
  List<Object?> get props => [sats, selectedTab, invoice];
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
