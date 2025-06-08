import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/core/disposable.dart';
import 'package:rxdart/rxdart.dart';

final class SessionUsecase implements Disposable {
  final _sessionStream = BehaviorSubject.seeded(const Session.unauth());

  SessionUsecase();

  Stream<Session> get sessionStream => _sessionStream.stream.distinct();

  Session get currentSession => _sessionStream.value;

  Future<void> setSession(Session session) async {
    _sessionStream.add(session);
  }

  @override
  Future<void> dispose() async {
    if (!_sessionStream.isClosed) {
      await _sessionStream.close();
    }
  }
}
