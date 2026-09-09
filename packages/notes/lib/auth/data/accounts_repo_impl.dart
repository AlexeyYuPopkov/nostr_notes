import 'package:nostr_notes/auth/domain/repo/accounts_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class AccountsRepoImpl implements AccountsRepo {
  static const _key = 'accounts_pubkeys';

  final SharedPreferences _prefs;

  AccountsRepoImpl(this._prefs);

  @override
  List<String> getAccounts() {
    return _prefs.getStringList(_key) ?? const [];
  }

  @override
  Future<void> addAccount(String pubkey) async {
    if (pubkey.isEmpty) {
      return;
    }

    final accounts = getAccounts();
    if (accounts.contains(pubkey)) {
      return;
    }

    await _prefs.setStringList(_key, [...accounts, pubkey]);
  }

  @override
  Future<void> removeAccount(String pubkey) async {
    final accounts = getAccounts();
    if (!accounts.contains(pubkey)) {
      return;
    }

    await _prefs.setStringList(
      _key,
      accounts.where((e) => e != pubkey).toList(),
    );
  }
}
