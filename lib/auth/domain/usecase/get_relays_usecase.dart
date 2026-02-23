import 'dart:async';

import 'package:collection/collection.dart';
import 'package:nostr_notes/auth/domain/model/relay_info.dart';
import 'package:nostr_notes/auth/domain/repo/relays_list_repo.dart';

final class GetRelaysUsecase {
  final RelaysListRepo _relaysListRepo;

  const GetRelaysUsecase({required RelaysListRepo relaysListRepo})
    : _relaysListRepo = relaysListRepo;

  FutureOr<GetRelaysUsecaseResult> execute() {
    return GetRelaysUsecaseResult(
      relays: _relaysListRepo
          .getSuggestedRelays()
          .map((url) => RelayInfo(url: Uri.parse(url)))
          .toList(),
      selected: _relaysListRepo
          .getRelaysList()
          .map((url) => RelayInfo(url: Uri.parse(url)))
          .toSet(),
    );
  }
}

final class GetRelaysUsecaseResult {
  final List<RelayInfo> relays;
  final Set<RelayInfo> selected;

  const GetRelaysUsecaseResult._({
    required this.relays,
    required this.selected,
  });

  factory GetRelaysUsecaseResult({
    required List<RelayInfo> relays,
    required Set<RelayInfo> selected,
  }) {
    return GetRelaysUsecaseResult._(
      relays: [
        ...selected.sorted((a, b) => a.compare(b)),
        ...relays
            .where((r) => !selected.contains(r))
            .sorted((a, b) => a.compare(b)),
      ],
      selected: selected,
    );
  }
}

extension on RelayInfo {
  int compare(RelayInfo other) => url.host.compareTo(other.url.host);
}
