final class FetchLightningPaymentParams {
  final String eventATag;
  final String eventPubkey;
  final String invoiceEventId;
  final String payerPubKey;
  final String clientTagValue;

  const FetchLightningPaymentParams({
    required this.eventATag,
    required this.eventPubkey,
    required this.invoiceEventId,
    required this.payerPubKey,
    required this.clientTagValue,
  });

  bool get hasRequiredTags => eventPubkey.isNotEmpty;

  bool get hasInvoiceScope => invoiceEventId.isNotEmpty;
}
