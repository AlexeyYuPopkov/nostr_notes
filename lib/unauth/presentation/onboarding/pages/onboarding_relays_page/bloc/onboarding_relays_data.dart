import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/relay_info.dart';

final class OnboardingRelaysData extends Equatable {
  final List<RelayInfo> relays;
  final Set<RelayInfo> selectedRelays;
  final Set<RelayInfo> initialRelays;

  const OnboardingRelaysData._({
    required this.relays,
    required this.selectedRelays,
    this.initialRelays = const {},
  });

  factory OnboardingRelaysData.initial() {
    return const OnboardingRelaysData._(
      relays: [],
      selectedRelays: {},
      initialRelays: {},
    );
  }

  bool isSelected(RelayInfo relay) => selectedRelays.contains(relay);

  bool get hasChanges =>
      !(const SetEquality().equals(selectedRelays, initialRelays));

  @override
  List<Object?> get props => [relays, selectedRelays];

  OnboardingRelaysData copyWith({
    List<RelayInfo>? relays,
    Set<RelayInfo>? selectedRelays,
    Set<RelayInfo>? initialRelays,
  }) {
    return OnboardingRelaysData._(
      relays: relays ?? this.relays,
      selectedRelays: selectedRelays ?? this.selectedRelays,
      initialRelays: initialRelays ?? this.initialRelays,
    );
  }
}
