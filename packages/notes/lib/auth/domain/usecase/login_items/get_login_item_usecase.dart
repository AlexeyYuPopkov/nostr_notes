import 'package:nostr_notes/auth/domain/model/login_item.dart';

/// Loads a single login item by its `dTag`, or `null` when not stored.
/// A decryption failure yields an item with `error` set, consistent with
/// `WatchLoginItemsUsecase`.
abstract interface class GetLoginItemUsecase {
  Future<LoginItem?> execute({required String dTag});
}
