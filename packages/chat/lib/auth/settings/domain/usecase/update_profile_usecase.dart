import 'package:chat/auth/settings/domain/models/profile_fields.dart';

abstract interface class UpdateProfileUsecase {
  /// Signs a new kind 0 that keeps every field of the current profile except
  /// [fields], stores it, then publishes it.
  ///
  /// Throws `ProfileNotPublishedException` when no relay accepted the event — the
  /// local store already has it.
  Future<void> execute(ProfileFields fields);
}
