import 'package:common/data/zap/fetch_user_zapper_service.dart';
import 'package:common/data/zap/lightning_donation_repo.dart';
import 'package:common/data/zap/perform_lighting_invoice_service.dart';
import 'package:common/services/event_store/database/daos/daos.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:di_storage/di_storage.dart';
import 'package:common/tools/app_worker/app_worker.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr/nostr_client/nostr_relay.dart';
import 'package:nostr/nostr_client/nostr_event_creator.dart';
import 'package:nostr_notes/auth/data/export_usecase_impl.dart';
import 'package:nostr_notes/auth/data/get_pending_usecase_impl.dart';
import 'package:nostr_notes/auth/data/import_usecase_impl.dart';
import 'package:nostr_notes/auth/data/lightning_donation_repo_impl.dart';
import 'package:nostr_notes/auth/data/notes_repository_impl.dart';
import 'package:nostr_notes/auth/domain/repo/notes_repository.dart';
import 'package:nostr_notes/auth/domain/usecase/create_note_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/delete_note_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/export_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/import_usecase.dart';
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
      () => NostrClient(
        batchParser: (batch, relayUrl) => AppWorker.instance.compute(
          params: (batch, relayUrl),
          callback: NostrRelayEventMapper.parseBatch,
        ),
      ),
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

    final OutboxDaoInterface outboxDao = di.resolve();

    di.bind<GetPendingUsecase>(
      () => GetPendingUsecaseImpl(outboxDao: outboxDao),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<ExportUsecase>(
      () => ExportUsecaseImpl(
        eventStore: di.resolve(),
        noteCryptoUseCase: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<ImportUsecase>(
      () => ImportUsecaseImpl(
        eventStore: di.resolve(),
        noteCryptoUseCase: di.resolve(),
        sessionUsecase: di.resolve(),
        outboxDao: outboxDao,
      ),
      module: this,
      lifeTime: const LifeTime.prototype(),
    );

    di.bind<LightningDonationRepo>(
      () => LightningDonationRepoImpl(
        sessionUsecase: di.resolve(),
        relaysListRepo: di.resolve(),
        performLightingInvoiceService: PerformLightingInvoiceService(
          fetchUserZapperService: const FetchUserZapperService(),
          zapEventCreator: const ZapEventCreator(
            eventCreator: NostrEventCreator(),
          ),
        ),
      ),
      module: this,
      lifeTime: const LifeTime.single(),
    );
  }
}
