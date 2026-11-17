import 'package:common/domain/model/user.dart';

abstract interface class GetUserUseCase {
  /// The stored kind 0 of [pubkey]: emitted at once and on every change.
  /// Never fetches from relays; a bare [User] while the store has none.
  Stream<User> execute({required String pubkey});
}
