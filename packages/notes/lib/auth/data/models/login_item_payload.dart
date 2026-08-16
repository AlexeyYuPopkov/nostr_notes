import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'login_item_payload.g.dart';

/// Versioned plaintext of a login item; the whole JSON object is encrypted
/// into a single NIP-44 blob that becomes the event `content`. Nothing from
/// here may ever be written to a plaintext event tag.
@immutable
@JsonSerializable(includeIfNull: false)
final class LoginItemPayload {
  static const int supportedVersion = 1;

  const LoginItemPayload({
    required this.v,
    required this.title,
    required this.username,
    required this.password,
    required this.url,
    required this.notes,
    required this.rev,
    this.updatedAt,
    this.image,
    this.totp,
  });

  factory LoginItemPayload.fromJson(Map<String, dynamic> json) {
    final payload = _$LoginItemPayloadFromJson(json);
    if (payload.v > supportedVersion) {
      throw UnsupportedLoginItemPayloadVersion(payload.v);
    }
    return payload;
  }

  /// Payload format version, bumped on breaking changes.
  final int v;
  final String title;
  final String username;
  final String password;
  final String url;
  final String notes;

  /// Last content change, seconds since epoch. Lives here — inside the
  /// ciphertext — rather than in a plaintext event tag, so edit timing
  /// semantics are not observable. Readers fall back to the event
  /// `created_at` when absent.
  @JsonKey(name: 'updated_at')
  final int? updatedAt;

  /// Image reference (site icon URL or asset id); absent when not set, so
  /// payloads written before the field existed parse unchanged.
  final String? image;

  /// Reserved for the TOTP feature.
  final String? totp;

  /// Content-save counter, see `LoginItem.revision`.
  final int rev;

  Map<String, dynamic> toJson() => _$LoginItemPayloadToJson(this);
}

/// Thrown when a stored payload was written by a newer app version with an
/// incompatible format. Surfaces the same way as a decryption failure.
final class UnsupportedLoginItemPayloadVersion implements Exception {
  final int version;

  const UnsupportedLoginItemPayloadVersion(this.version);

  @override
  String toString() =>
      'UnsupportedLoginItemPayloadVersion: payload v$version is newer than '
      'supported v${LoginItemPayload.supportedVersion}';
}
