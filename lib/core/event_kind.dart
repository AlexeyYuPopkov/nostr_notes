enum EventKind {
  /// Parameterized Replaceable Events, NIP-33
  note(30023),
  delete(5);

  final int value;
  const EventKind(this.value);
}

abstract final class NostrKind {
  static const int deletion = 5;
}
