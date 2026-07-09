abstract interface class AccountsRepo {
  List<String> getAccounts();

  Future<void> addAccount(String pubkey);

  Future<void> removeAccount(String pubkey);
}
