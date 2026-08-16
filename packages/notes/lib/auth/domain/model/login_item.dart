import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/encrypted_login_item.dart';

/// A decrypted credential item ("account note").
///
/// The at-rest twin is [EncryptedLoginItem]; conversion between the two is
/// the job of `LoginItemCryptoUsecase`. All secret fields ([title],
/// [username], [password], [websiteUrl], [notes], [totpSecret], [revision])
/// travel inside a single NIP-44 encrypted payload — none of them appear in
/// plaintext event tags.
final class LoginItem extends Equatable {
  final String eventId;
  final String dTag;
  final String title;
  final String username;
  final String password;
  final String websiteUrl;
  final String notes;

  /// Image reference for the item (e.g. a site icon URL or asset id).
  /// Encrypted like every other field — even an icon URL reveals which
  /// service the credential belongs to.
  final String image;

  /// Reserved for the TOTP feature; part of payload v1 from the start so
  /// adding it later does not require a payload format migration.
  final String? totpSecret;

  /// Incremented on every content save. Stored inside the encrypted payload,
  /// so edit intensity is not observable in plaintext. Intended for UI
  /// sorting by "how often the user updates the item".
  final int revision;

  /// Event publication timestamp; refreshed on every save and used by the
  /// event store (and relays) to resolve replaceable-event conflicts.
  final DateTime createdAt;

  /// Last content change time. Carried inside the encrypted payload (never
  /// in a plaintext tag), so edit timing semantics stay private.
  final DateTime updatedAt;

  /// Non-null when the stored payload could not be decrypted; such items
  /// render as locked in the UI instead of being dropped.
  final Object? error;

  const LoginItem({
    required this.eventId,
    required this.dTag,
    required this.title,
    required this.username,
    required this.password,
    required this.websiteUrl,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.image = '',
    this.totpSecret,
    this.revision = 0,
    this.error,
  });

  /// A blank unsaved item; `SaveLoginItemUsecase` assigns [dTag], [eventId]
  /// and timestamps on the first save.
  factory LoginItem.draft({
    String title = '',
    String username = '',
    String password = '',
    String websiteUrl = '',
    String notes = '',
    String image = '',
  }) {
    return LoginItem(
      eventId: '',
      dTag: '',
      title: title,
      username: username,
      password: password,
      websiteUrl: websiteUrl,
      notes: notes,
      image: image,
      createdAt: DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true),
      updatedAt: DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true),
    );
  }

  /// An item whose payload could not be decrypted: identity and timestamps
  /// are preserved, secret fields are blank, [error] carries the cause.
  factory LoginItem.locked(EncryptedLoginItem source, Object error) {
    return LoginItem(
      eventId: source.eventId,
      dTag: source.dTag,
      title: '',
      username: '',
      password: '',
      websiteUrl: '',
      notes: '',
      createdAt: source.createdAt,
      // The real value is inside the payload we failed to decrypt.
      updatedAt: source.createdAt,
      error: error,
    );
  }

  bool get isNew => dTag.isEmpty;

  LoginItem copyWith({
    String? title,
    String? username,
    String? password,
    String? websiteUrl,
    String? notes,
    String? image,
    String? totpSecret,
    Object? error,
    bool clearError = false,
  }) {
    return LoginItem(
      eventId: eventId,
      dTag: dTag,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      notes: notes ?? this.notes,
      image: image ?? this.image,
      totpSecret: totpSecret ?? this.totpSecret,
      revision: revision,
      createdAt: createdAt,
      updatedAt: updatedAt,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    eventId,
    dTag,
    title,
    username,
    password,
    websiteUrl,
    notes,
    image,
    totpSecret,
    revision,
    createdAt,
    updatedAt,
    error,
  ];
}
