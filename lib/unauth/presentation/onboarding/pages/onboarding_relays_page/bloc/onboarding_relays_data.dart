import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/relay_info.dart';

final class OnboardingRelaysData extends Equatable {
  final List<RelayInfo> relays;
  final Set<RelayInfo> selectedRelays;

  const OnboardingRelaysData._({
    required this.relays,
    required this.selectedRelays,
  });

  factory OnboardingRelaysData.initial() {
    return const OnboardingRelaysData._(relays: [], selectedRelays: {});
  }

  bool isSelected(relay) => selectedRelays.contains(relay);

  @override
  List<Object?> get props => [relays, selectedRelays];

  OnboardingRelaysData copyWith({
    List<RelayInfo>? relays,
    Set<RelayInfo>? selectedRelays,
  }) {
    return OnboardingRelaysData._(
      relays: relays ?? this.relays,
      selectedRelays: selectedRelays ?? this.selectedRelays,
    );
  }
}
