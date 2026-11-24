import 'package:collection/collection.dart';
import 'package:common/domain/model/relay_info.dart';
import 'package:equatable/equatable.dart';

final class RelaysData extends Equatable {
  final List<RelayInfo> relays;
  final Set<RelayInfo> selectedRelays;
  final Set<RelayInfo> initialRelays;

  const RelaysData._({
    required this.relays,
    required this.selectedRelays,
    this.initialRelays = const {},
  });

  factory RelaysData.initial() {
    return const RelaysData._(
      relays: [],
      selectedRelays: {},
      initialRelays: {},
    );
  }

  bool isSelected(RelayInfo relay) => selectedRelays.contains(relay);

  bool get hasChanges =>
      !(const SetEquality().equals(selectedRelays, initialRelays));

  @override
  List<Object?> get props => [relays, selectedRelays, initialRelays];

  RelaysData copyWith({
    List<RelayInfo>? relays,
    Set<RelayInfo>? selectedRelays,
    Set<RelayInfo>? initialRelays,
  }) {
    return RelaysData._(
      relays: relays ?? this.relays,
      selectedRelays: selectedRelays ?? this.selectedRelays,
      initialRelays: initialRelays ?? this.initialRelays,
    );
  }
}
