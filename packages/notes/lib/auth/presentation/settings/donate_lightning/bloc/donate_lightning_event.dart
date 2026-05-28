import 'package:equatable/equatable.dart';
import '../tabs/donation_screen_tab.dart';

sealed class DonateLightningEvent extends Equatable {
  const DonateLightningEvent();

  const factory DonateLightningEvent.updateSats(int sats) = UpdateSatsEvent;
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

final class ChangeTabEvent extends DonateLightningEvent {
  final DonationScreenTab selectedTab;
  const ChangeTabEvent({required this.selectedTab});

  @override
  List<Object?> get props => [selectedTab];
}

final class SubmitEvent extends DonateLightningEvent {
  const SubmitEvent();
}
