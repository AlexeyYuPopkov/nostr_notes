/// Repository interface for sending lightning donations.
abstract interface class LightningDonationRepo {
  /// Generates a BOLT-11 invoice for [sats] satoshis and returns it.
  Future<String> getInvoice({required int sats});
}
