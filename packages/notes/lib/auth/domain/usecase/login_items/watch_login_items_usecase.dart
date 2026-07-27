import 'package:nostr_notes/auth/domain/model/login_item.dart';

/// Watches all login items of the current account, decrypted and sorted by
/// `updatedAt` descending. Items that fail to decrypt are emitted with
/// `error` set (rendered as locked) rather than dropped.
abstract interface class WatchLoginItemsUsecase {
  Stream<List<LoginItem>> execute();
}
