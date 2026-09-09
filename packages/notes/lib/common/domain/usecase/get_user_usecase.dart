import 'package:nostr_notes/common/domain/model/user.dart';

abstract interface class GetUserUsecase {
  Stream<User?> execute({required String pubkey, bool force = false});
}
