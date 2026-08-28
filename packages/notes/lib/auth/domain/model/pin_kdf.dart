/// Which key-derivation function turned the PIN into key material for a
/// given piece of ciphertext.
///
/// Notes carry this in the [tagName] tag of their Nostr event, so a note
/// written before PBKDF2 landed still decrypts. Login items don't: they
/// were never released, so everything on a relay is already [pbkdf2].
enum PinKdf {
  /// A single SHA-256 pass over the PIN — no salt, no stretching. Only for
  /// reading notes written before the tag existed; never chosen for new
  /// ciphertext. This is the one value that writes no tag at all.
  legacySha256('1'),

  /// No PIN took part: the key is the plain NIP-44 conversation key, so the
  /// note opens with the account keys alone. Recorded explicitly rather than
  /// left implicit — a reader must not apply a PIN the writer never used,
  /// and a note with no PIN protection should say so.
  none('0'),

  /// PBKDF2-HMAC-SHA256, [pbkdf2Iterations] rounds, salted per account.
  pbkdf2('2');

  final String tagValue;

  const PinKdf(this.tagValue);

  /// Nostr event tag naming the KDF. An event without it predates versioning.
  static const tagName = 'pin_kdf';

  /// What new ciphertext is written with.
  static const current = PinKdf.pbkdf2;

  /// Measured at ~640 ms on a desktop CPU in pure Dart, which lands in the
  /// low seconds on a mid-range phone. Paid once per unlock: on mobile in an
  /// isolate, in the browser by Web Crypto (`Pbkdf2` resolves to
  /// `BrowserPbkdf2` there, so no isolate is needed and none exists).
  ///
  /// Raising it buys less than the wall clock suggests — an attacker runs
  /// native SHA-256, we run Dart. See `doc/pbkdf2.md`.
  static const pbkdf2Iterations = 200000;

  /// Domain separation so the salt can never collide with another PBKDF2 use
  /// in this app (the backup password has its own, random, stored salt).
  static const saltInfo = 'nostr-notes:pin-kdf:v2';

  /// The event tag recording this KDF, or null for [legacySha256] — an absent
  /// tag is exactly how a pre-migration note is recognised.
  ///
  /// Every place that builds a note event must emit this; `NoteMapper` is not
  /// the only one (`NotesRepositoryImpl.publishNote` assembles its own tags).
  List<String>? get tag =>
      this == PinKdf.legacySha256 ? null : [tagName, tagValue];

  /// Whether the PIN is mixed into the key at all. [none] is the derivation
  /// that does nothing, so it must not be handed a password.
  bool get usesPin => this != PinKdf.none;

  /// Absent tag means the note predates versioning, hence [legacySha256].
  static PinKdf fromTagValue(String? value) {
    if (value == null || value.isEmpty) return PinKdf.legacySha256;
    return PinKdf.values.firstWhere(
      (kdf) => kdf.tagValue == value,
      orElse: () => PinKdf.legacySha256,
    );
  }
}
