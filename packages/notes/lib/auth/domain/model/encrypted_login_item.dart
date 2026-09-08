import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/pin_kdf.dart';

/// The at-rest representation of a [LoginItem]: everything sensitive is
/// inside [encryptedPayload] (a single NIP-44 blob of the payload JSON).
/// This is the only shape mappers and the event store ever see.
final class EncryptedLoginItem extends Equatable {
  final String eventId;
  final String dTag;
  final String encryptedPayload;
  final DateTime createdAt;

  /// Which derivation produced the key for [encryptedPayload]. Without it,
  /// an item written while the account had no PIN becomes unreadable the
  /// moment a PIN is set — the reader would apply one the writer never used.
  final PinKdf kdf;

  const EncryptedLoginItem({
    required this.eventId,
    required this.dTag,
    required this.encryptedPayload,
    required this.createdAt,
    this.kdf = PinKdf.current,
  });

  @override
  List<Object?> get props => [eventId, dTag, encryptedPayload, createdAt, kdf];
}
