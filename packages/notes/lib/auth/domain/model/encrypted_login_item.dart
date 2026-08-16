import 'package:equatable/equatable.dart';

/// The at-rest representation of a [LoginItem]: everything sensitive is
/// inside [encryptedPayload] (a single NIP-44 blob of the payload JSON).
/// This is the only shape mappers and the event store ever see.
final class EncryptedLoginItem extends Equatable {
  final String eventId;
  final String dTag;
  final String encryptedPayload;
  final DateTime createdAt;

  const EncryptedLoginItem({
    required this.eventId,
    required this.dTag,
    required this.encryptedPayload,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [eventId, dTag, encryptedPayload, createdAt];
}
