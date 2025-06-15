import 'package:di_storage/di_storage.dart';
import 'package:nostr_notes/auth/domain/create_note_usecase.dart';
import 'package:nostr_notes/common/data/event_publisher_impl.dart';
import 'package:nostr_notes/common/domain/event_publisher.dart';
import 'package:nostr_notes/core/services/nostr_client.dart';

final class AuthDiScope extends DiScope {
  const AuthDiScope();

  @override
  void bind(DiStorage di) {
    di.bind<NostrClient>(
      () => NostrClient(),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<EventPublisher>(
      () => EventPublisherImpl(
        nostrClient: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<CreateNoteUsecase>(
      () => CreateNoteUsecase(
        sessionUsecase: di.resolve(),
        eventPublisher: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );
  }
}
