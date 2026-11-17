import 'package:chat/auth/settings/domain/models/profile_exception.dart';
import 'package:chat/auth/settings/domain/models/profile_fields.dart';
import 'package:chat/auth/settings/domain/usecase/get_current_profile_usecase.dart';
import 'package:chat/auth/settings/domain/usecase/update_profile_usecase.dart';
import 'package:common/domain/model/user.dart';
import 'package:rxdart/rxdart.dart';

const profilePubkey =
    '82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2';

/// The local store as the profile screen sees it: saving updates it at once,
/// as the real usecase does before publishing.
final class FakeProfileStore {
  final BehaviorSubject<User> _profile;
  bool relaysAccept = true;

  FakeProfileStore({required String name})
    : _profile = BehaviorSubject.seeded(
        User(pubkey: profilePubkey, name: name),
      );

  User get savedProfile => _profile.value;

  Future<void> close() => _profile.close();
}

final class FakeGetCurrentProfileUsecase implements GetCurrentProfileUsecase {
  final FakeProfileStore _store;

  const FakeGetCurrentProfileUsecase(this._store);

  @override
  Stream<User> execute() => _store._profile.stream;
}

final class FakeUpdateProfileUsecase implements UpdateProfileUsecase {
  final FakeProfileStore _store;

  const FakeUpdateProfileUsecase(this._store);

  @override
  Future<void> execute(ProfileFields fields) async {
    final trimmed = fields.trimmed();
    _store._profile.add(
      User(
        pubkey: profilePubkey,
        name: _nullIfEmpty(trimmed.name),
        displayName: _nullIfEmpty(trimmed.displayName),
        picture: _nullIfEmpty(trimmed.picture),
      ),
    );
    if (!_store.relaysAccept) {
      throw const ProfileNotPublishedException();
    }
  }

  static String? _nullIfEmpty(String value) => value.isEmpty ? null : value;
}
