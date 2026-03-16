abstract interface class DesktopRatioRepo {
  double? getForUser(String pubkey);

  Future<void> setForUser(double ratio, {required String pubkey});
}
