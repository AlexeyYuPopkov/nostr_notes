import 'package:nostr_notes/auth/domain/model/login_item.dart';

/// Deletes a login item everywhere: an empty-content tombstone overwrites
/// the replaceable slot and a NIP-09 deletion request asks relays (and other
/// devices) to drop it; both are queued through the outbox.
abstract interface class DeleteLoginItemUsecase {
  Future<void> execute({required LoginItem item});
}
