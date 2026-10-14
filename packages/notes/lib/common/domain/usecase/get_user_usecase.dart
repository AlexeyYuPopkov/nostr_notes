import 'package:nostr_notes/common/domain/model/user.dart';

abstract interface class GetUserUsecase {
  /// Emits the stored profile (`null` while none is stored), then every newer
  /// one as it is fetched or saved. Never completes; cancel to stop.
  Stream<User?> execute({required String pubkey, bool force = false});
}
