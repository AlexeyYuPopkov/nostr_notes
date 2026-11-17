sealed class ProfileException implements Exception {
  const ProfileException();
}

final class ProfileNoSessionException extends ProfileException {
  const ProfileNoSessionException();
}

final class ProfileInvalidPictureException extends ProfileException {
  const ProfileInvalidPictureException();
}

/// The new profile is in the local store, but no relay confirmed it.
final class ProfileNotPublishedException extends ProfileException {
  const ProfileNotPublishedException();
}
