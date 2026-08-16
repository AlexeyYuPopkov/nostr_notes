import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:uuid/uuid.dart';

/// Creates or updates a login item.
///
/// For a draft (empty `dTag`) assigns a new `dTag` and starts the revision
/// counter at 0; for an existing item bumps `revision` and refreshes the
/// timestamps so the stored version is superseded. The resulting event is
/// signed by the vault identity, persisted locally, and queued to the outbox
/// for relay sync.
abstract interface class SaveLoginItemUsecase {
  Future<LoginItem> execute({required LoginItem item, Now? now, Uuid? uuid});
}
