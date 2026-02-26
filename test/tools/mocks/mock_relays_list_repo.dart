import 'package:nostr_notes/auth/data/relays_list_repo_impl.dart';
import 'package:nostr_notes/auth/domain/repo/relays_list_repo.dart';
import 'package:rxdart/subjects.dart';

class MockRelaysListRepo implements RelaysListRepo {
  static const relayUrl1 = 'wss://relay1.example.com';
  static const relayUrl2 = 'wss://relay2.example.com';

  late final BehaviorSubject _relaysListSubject =
      BehaviorSubject<Set<String>>.seeded({});

  MockRelaysListRepo();

  factory MockRelaysListRepo.withStubRelays() {
    final repo = MockRelaysListRepo();
    repo._relaysListSubject.add({relayUrl1, relayUrl2});
    return repo;
  }

  factory MockRelaysListRepo.withRelays(Set<String> relays) {
    final repo = MockRelaysListRepo();
    repo._relaysListSubject.add(relays);
    return repo;
  }

  @override
  @override
  Set<String> getRelaysList() {
    return _relaysListSubject.value;
  }

  @override
  Future<void> saveRelaysList(Set<String> relays) async {
    _relaysListSubject.add(relays);
  }

  @override
  Set<String> getSuggestedRelays() {
    return RelaysListRepoImpl.suggestedRelays;
  }

  @override
  Stream<Set<String>> get relaysListStream => Stream.value(getRelaysList());

  @override
  Future<void> clear() async {
    _relaysListSubject.add(<String>{});
  }
}
