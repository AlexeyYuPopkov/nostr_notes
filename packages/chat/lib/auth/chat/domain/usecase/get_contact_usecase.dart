import 'package:common/domain/model/user.dart';

abstract interface class GetContactUsecase {
  /// The stored kind 0 of [pubkey], or a bare [User] until it arrives.
  /// Fetches it from relays when the store has none.
  Stream<User> execute(String pubkey);
}
