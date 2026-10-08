import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'keys_backup_payload.g.dart';

/// The JSON stored in a keys backup zip. Always encrypted: a private key is a
/// directly usable credential.
@immutable
@JsonSerializable(includeIfNull: false, explicitToJson: true)
final class KeysBackupPayload {
  static const supportedVersion = 1;

  /// Tells a keys backup apart from a notes or accounts backup, which share
  /// the envelope fields.
  static const payloadType = 'nostr_keys';

  const KeysBackupPayload({
    required this.version,
    required this.type,
    required this.salt,
    required this.iterations,
    required this.keys,
    this.exportedAt,
  });

  factory KeysBackupPayload.fromJson(Map<String, dynamic> json) =>
      _$KeysBackupPayloadFromJson(json);

  final int version;
  final String type;

  /// ISO-8601 UTC timestamp of when the backup was created.
  @JsonKey(name: 'exported_at')
  final String? exportedAt;

  /// Hex-encoded random PBKDF2 salt.
  final String salt;

  final int iterations;

  final List<KeysBackupRecord> keys;

  Map<String, dynamic> toJson() => _$KeysBackupPayloadToJson(this);
}

@immutable
@JsonSerializable(includeIfNull: false)
final class KeysBackupRecord {
  const KeysBackupRecord({required this.npub, required this.nsec, this.label});

  factory KeysBackupRecord.fromJson(Map<String, dynamic> json) =>
      _$KeysBackupRecordFromJson(json);

  /// Plain text, so a backup can be identified without the password.
  final String npub;

  final String? label;

  /// `base64(ciphertext)?iv=base64(iv)&mac=base64(mac)`, see
  /// `BackupCryptoHelper.encryptField`.
  final String nsec;

  Map<String, dynamic> toJson() => _$KeysBackupRecordToJson(this);
}
