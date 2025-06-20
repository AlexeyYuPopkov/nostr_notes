import 'package:nostr_notes/auth/domain/repo/relays_list_repo.dart';

final class RelaysListRepoImpl implements RelaysListRepo {
  const RelaysListRepoImpl();
  @override
  List<String> getRelaysList() {
    return [
      'wss://relay.nostr.band/all',
      'wss://relay.damus.io',
    ];
  }
}
