import 'package:di_storage/di_storage.dart';
import 'package:nostr_notes/auth/data/common_event_storage_impl.dart';
import 'package:nostr_notes/auth/data/notes_repository_impl.dart';
import 'package:nostr_notes/auth/data/relays_list_repo_impl.dart';
import 'package:nostr_notes/auth/domain/repo/relays_list_repo.dart';
import 'package:nostr_notes/auth/domain/usecase/create_note_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/fetch_notes_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_notes_usecase.dart';
import 'package:nostr_notes/common/data/event_publisher_impl.dart';
import 'package:nostr_notes/common/domain/event_publisher.dart';
import 'package:nostr_notes/services/nostr_client.dart';

final class AuthDiScope extends DiScope {
  const AuthDiScope();

  @override
  void bind(DiStorage di) {
    di.bind<RelaysListRepo>(
      () => const RelaysListRepoImpl(),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    di.bind<NostrClient>(
      () => NostrClient(),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<EventPublisher>(
      () => EventPublisherImpl(
        nostrClient: di.resolve(),
        relaysListRepo: di.resolve<RelaysListRepo>(),
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

    di.bind<CommonEventStorage>(
      () => CommonEventStorageImpl(),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    di.bind<FetchNotesUsecase>(
      () => FetchNotesUsecase(
        notesRepository: NotesRepositoryImpl(
          client: di.resolve<NostrClient>(),
          memoryStorage: di.resolve(),
        ),
        sessionUsecase: di.resolve(),
        relaysListRepo: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<GetNotesUsecase>(
      () => GetNotesUsecase(
        notesRepository: NotesRepositoryImpl(
          client: di.resolve<NostrClient>(),
          memoryStorage: di.resolve(),
        ),
        sessionUsecase: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );
  }
}
