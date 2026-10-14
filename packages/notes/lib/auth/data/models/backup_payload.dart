import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:nostr_notes/common/data/backup/backup_zip_helper.dart';

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

  /// Null if [archivedFileName] isn't present in the zip.
  static BackupPayload? fromZip(List<int> bytes, String archivedFileName) {
    final json = BackupZipHelper.readJson(bytes, archivedFileName);
    return json == null ? null : BackupPayload.fromJson(json);
  }

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
