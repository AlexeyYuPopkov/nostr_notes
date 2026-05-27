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
    final satsAmount = zaps.fold<int>(0, (sum, zap) {
      return zap.isValid ? sum + zap.invoiceSats : sum;
    });

    return ZapConfirmationSum._(satsAmount: satsAmount);
  }
}
