import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'backup_payload.g.dart';

@immutable
@JsonSerializable(includeIfNull: false, explicitToJson: true)
final class BackupPayload {
  const BackupPayload({
    required this.version,
    required this.encrypted,
    required this.events,
    this.exportedAt,
    this.salt,
    this.iterations,
  });

  factory BackupPayload.fromJson(Map<String, dynamic> json) =>
      _$BackupPayloadFromJson(json);

  final int version;
  final bool encrypted;

  /// ISO-8601 UTC timestamp of when the backup was created.
  @JsonKey(name: 'exported_at')
  final String? exportedAt;

  /// Hex-encoded random salt; present only when [encrypted] is true.
  final String? salt;

  /// PBKDF2 iteration count; present only when [encrypted] is true.
  final int? iterations;

  /// Raw Nostr event JSON objects (content/summary are AES-encrypted when [encrypted] is true).
  final List<Map<String, dynamic>> events;

  Map<String, dynamic> toJson() => _$BackupPayloadToJson(this);
}
