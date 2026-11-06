import 'package:common/domain/model/user.dart';

abstract interface class GetCurrentProfileUsecase {
  /// The signed-in user's profile from the local store: emitted at once and
  /// on every change. Each subscription also refreshes it from relays once.
  /// Without a stored profile it emits a bare `User(pubkey: ...)`.
  Stream<User> execute();
}
