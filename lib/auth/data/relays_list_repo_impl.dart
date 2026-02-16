import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/auth/domain/repo/relays_list_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class RelaysListRepoImpl implements RelaysListRepo {
  static const _suggestedRelays = {
    'wss://relay.damus.io',
    'wss://nos.lol',
    'wss://relay.nostr.band',
    'wss://relay.snort.social',
  };

  final SharedPreferences _prefs;
  static const _key = 'relay_urls';

  RelaysListRepoImpl(this._prefs);

  @override
  Set<String> getRelaysList() {
    // return {};
    final relayUrl = AppConfig.relayUrl;
    if (relayUrl != null && relayUrl.isNotEmpty) {
      return {relayUrl};
    }
    return {'wss://relay.damus.io'}; // или _prefs.getStringList(_key) ?? [];
  }

  @override
  Future<void> saveRelaysList(List<String> relays) async {
    await _prefs.setStringList(_key, relays);
  }

  @override
  Set<String> getSuggestedRelays() => _suggestedRelays;
}
