import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:common/tools/disposable.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class RelaysListRepoImpl implements RelaysListRepo, Disposable {
  static const suggestedRelays = {
    'wss://nos.lol',
    // 'wss://relay.snort.social',
    'wss://relay.primal.net',
    'wss://purplepag.es',
    'wss://nostr.mom',
    'wss://relay.damus.io',
  };

  final SharedPreferences _prefs;
  final Set<String> _suggestedRelays;
  static const _key = 'relay_urls';
  late final BehaviorSubject<Set<String>> _behaviorSubject =
      BehaviorSubject<Set<String>>.seeded(_getRelaysList());

  RelaysListRepoImpl(
    this._prefs, {
    this._suggestedRelays = RelaysListRepoImpl.suggestedRelays,
  });

  @override
  Set<String> getRelaysList() => _behaviorSubject.value;

  @override
  Set<String> getSuggestedRelays() => _suggestedRelays;

  @override
  Stream<Set<String>> get relaysListStream => _behaviorSubject.stream;

  @override
  Future<void> saveRelaysList(Set<String> relays) async {
    await _prefs.setStringList(_key, relays.toList());
    _behaviorSubject.add(_getRelaysList());
  }

  @override
  Future<void> dispose() {
    return _behaviorSubject.close();
  }

  Set<String> _getRelaysList() {
    // final relayUrl = AppConfig.relayUrl;
    // if (relayUrl != null && relayUrl.isNotEmpty) {
    //   return {relayUrl};
    // }
    return {...?_prefs.getStringList(_key)};
  }

  @override
  Future<void> clear() => saveRelaysList({});
}
