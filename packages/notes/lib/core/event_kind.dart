enum EventKind {
  /// Parameterized Replaceable Events, NIP-33
  note(30023),
  delete(5);

  final int value;
  const EventKind(this.value);
}

abstract final class NostrKind {
  static const int user = 0;
  // [note = 30023]
  static const int note = 30023;

  /// Login item ("account note"), NIP-33 parameterized replaceable.
  /// Custom kind, unregistered in the NIPs registry as of 2026-07.
  /// Authored by the pseudonymous vault identity (never the account pubkey)
  /// and synced to relays through the outbox; see `VaultIdentityUsecase`.
  /// [loginItem = 31023]
  static const int loginItem = 31023;
  static const int deletion = 5;

  /// [zapConfirmation = 9735]
  static const zapConfirmation = 9735;

  /// [zapInvoice = 9734]
  static const zapInvoice = 9734;
}
