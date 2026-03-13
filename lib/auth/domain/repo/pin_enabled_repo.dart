abstract interface class PinEnabledRepo {
  bool getForUser(String pubkey);

  Future<void> setForUser(bool isEnabled, {required String pubkey});
}
