import 'package:common/data/zap/lightning_donation_repo.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:di_storage/di_storage.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr_notes/auth/data/get_pending_usecase_impl.dart';
import 'package:nostr_notes/auth/data/lightning_donation_repo_impl.dart';
import 'package:nostr_notes/auth/data/notes_repository_impl.dart';
import 'package:nostr_notes/auth/domain/repo/notes_repository.dart';
import 'package:nostr_notes/auth/domain/usecase/create_note_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/delete_note_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/fetch_notes_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_note_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_notes_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_pending_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:nostr_notes/services/outbox_publisher.dart';

final class AuthDiScope extends DiScope {
  const AuthDiScope();

  @override
  void bind(DiStorage di) {
    di.bind<NostrClient>(
      () => NostrClient(),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    di.bind<Connectivity>(
      () => Connectivity(),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    di.bind<OutboxPublisher>(
      () {
        return OutboxPublisher(
          outboxDao: di.resolve(),
          rawEventStore: di.resolve(),
          relaysListRepo: di.resolve(),
          channelFactory: const ChannelFactory(),
          connectivity: di.resolve(),
        );
      },
      module: this,
      lifeTime: const LifeTime.single(),
      onRemove: (e) {
        if (e is OutboxPublisher) {
          e.dispose();
        }
      },
    );

    // di.bind<EventPublisher>(
    //   () => EventPublisherImpl(
    //     nostrClient: di.resolve(),
    //     relaysListRepo: di.resolve<RelaysListRepo>(),
    //   ),
    //   module: this,
    //   lifeTime: const LifeTime.prototype(),
    // );

    di.bind<CreateNoteUsecase>(
      () => CreateNoteUsecase(
        sessionUsecase: di.resolve(),
        noteCryptoUseCase: di.resolve<NoteCryptoUseCase>(),
        notesRepository: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<DeleteNoteUsecase>(
      () => DeleteNoteUsecase(
        sessionUsecase: di.resolve(),
        notesRepository: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    di.bind<NotesRepository>(
      () => NotesRepositoryImpl(
        client: di.resolve<NostrClient>(),
        outboxDao: di.resolve(),
        eventStore: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    di.bind<FetchNotesUsecase>(
      () => FetchNotesUsecase(
        notesRepository: di.resolve(),
        sessionUsecase: di.resolve(),
        relaysListRepo: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<NoteCryptoUseCase>(
      () => NoteCryptoUseCase(
        sessionUsecase: di.resolve(),
        cryptoService: di.resolve(),
        extraDerivation: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    di.bind<GetNotesUsecase>(
      () => GetNotesUsecase(
        notesRepository: di.resolve(),
        sessionUsecase: di.resolve(),
        noteCryptoUseCase: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<GetNoteUsecase>(
      () => GetNoteUsecase(
        notesRepository: di.resolve(),
        sessionUsecase: di.resolve(),
        noteCryptoUseCase: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<GetPendingUsecase>(
      () => GetPendingUsecaseImpl(outboxDao: di.resolve()),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<LightningDonationRepo>(
      () => LightningDonationRepoImpl(
        sessionUsecase: di.resolve(),
        relaysListRepo: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.single(),
    );
  }
}
