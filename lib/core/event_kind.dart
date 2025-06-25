enum EventKind {
  /// Parameterized Replaceable Events, NIP-33
  note(30023);

  final int value;
  const EventKind(this.value);
}
