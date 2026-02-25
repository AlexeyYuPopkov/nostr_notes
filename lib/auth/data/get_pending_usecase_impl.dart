import 'package:nostr_notes/auth/domain/usecase/get_pending_usecase.dart';
import 'package:nostr_notes/services/event_store/database/daos/outbox_dao_interface.dart';

final class GetPendingUsecaseImpl implements GetPendingUsecase {
  final OutboxDaoInterface _outboxDao;

  GetPendingUsecaseImpl({required OutboxDaoInterface outboxDao})
    : _outboxDao = outboxDao;

  @override
  Stream<Set<String>> execute() {
    return _outboxDao.watchPending().map(
      (events) => events.map((e) => e.eventId).toSet(),
    );
  }
}
