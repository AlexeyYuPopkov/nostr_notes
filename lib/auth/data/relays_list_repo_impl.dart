import 'package:nostr_notes/auth/domain/repo/relays_list_repo.dart';
import 'package:nostr_notes/core/tools/disposable.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class RelaysListRepoImpl implements RelaysListRepo, Disposable {
  static const suggestedRelays = {
    'wss://relay.damus.io',
    'wss://nos.lol',
    'wss://relay.snort.social',
  };

  final SharedPreferences _prefs;
  static const _key = 'relay_urls';
  late final BehaviorSubject<Set<String>> _behaviorSubject =
      BehaviorSubject<Set<String>>.seeded(_getRelaysList());

  RelaysListRepoImpl(this._prefs);

  @override
  Set<String> getRelaysList() => _behaviorSubject.value;

  @override
  Set<String> getSuggestedRelays() => suggestedRelays;

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
