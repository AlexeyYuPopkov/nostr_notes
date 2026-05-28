abstract interface class ZapConfirmation {
  String get id;
  int get kind;
  bool get isValid;
  String get invoiceId;
  int get invoiceKind;
  int get invoiceSats;
}

final class ZapConfirmationSum {
  final int satsAmount;

  ZapConfirmationSum._({required this.satsAmount});

  factory ZapConfirmationSum.fromEvents(List<ZapConfirmation> zaps) {
    int satsAmount = 0;
    final ids = <String>{};
    for (final zap in zaps) {
      if (zap.isValid && !ids.contains(zap.id)) {
        satsAmount += zap.invoiceSats;
        ids.add(zap.id);
      }
    }

    return ZapConfirmationSum._(satsAmount: satsAmount);
  }
}
