import 'package:nostr_notes/auth/domain/repo/accounts_repo.dart';

class MockAccountsRepo implements AccountsRepo {
  final List<String> _accounts = [];

  @override
  List<String> getAccounts() => List.unmodifiable(_accounts);

  @override
  Future<void> addAccount(String pubkey) async {
    if (pubkey.isEmpty || _accounts.contains(pubkey)) {
      return;
    }
    _accounts.add(pubkey);
  }

  @override
  Future<void> removeAccount(String pubkey) async {
    _accounts.remove(pubkey);
  }
}
