sealed class Nip44Exception implements Exception {
  final String message;

  const Nip44Exception(this.message);

  @override
  String toString() => 'Nip44Exception: $message';
}

final class InvalidConversationKeyLengthNip44Exception extends Nip44Exception {
  const InvalidConversationKeyLengthNip44Exception()
    : super('Invalid conversation key length');
}

final class InvalidNonceLengthNip44Exception extends Nip44Exception {
  const InvalidNonceLengthNip44Exception() : super('Invalid nonce length');
}

final class InvalidPlaintextLengthNip44Exception extends Nip44Exception {
  const InvalidPlaintextLengthNip44Exception()
    : super('Invalid plaintext length');
}

final class InvalidPaddingNip44Exception extends Nip44Exception {
  const InvalidPaddingNip44Exception() : super('Invalid padding');
}

final class UnknownVersionNip44Exception extends Nip44Exception {
  const UnknownVersionNip44Exception() : super('Unknown version');
}

final class InvalidPayloadSizeNip44Exception extends Nip44Exception {
  const InvalidPayloadSizeNip44Exception() : super('Invalid payload size');
}

final class InvalidPayloadEncodingNip44Exception extends Nip44Exception {
  const InvalidPayloadEncodingNip44Exception()
    : super('Invalid payload encoding');
}

final class UnsupportedVersionNip44Exception extends Nip44Exception {
  const UnsupportedVersionNip44Exception() : super('Unsupported version');
}

final class InvalidMacNip44Exception extends Nip44Exception {
  const InvalidMacNip44Exception() : super('Invalid MAC');
}

final class InvalidPublicKeyNip44Exception extends Nip44Exception {
  const InvalidPublicKeyNip44Exception() : super('Invalid Public Key');
}
