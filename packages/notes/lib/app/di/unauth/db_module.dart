import 'package:di_storage/di_storage.dart';
import 'package:nostr_notes/services/event_store/database/app_database.dart';
import 'package:nostr_notes/services/event_store/database/daos/nostr_event_dao.dart';
import 'package:nostr_notes/services/event_store/database/daos/outbox_dao.dart';
import 'package:nostr_notes/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:nostr_notes/services/event_store/drift_event_store.dart';
import 'package:nostr_notes/services/event_store/raw_event_store.dart';
import 'package:nostr_notes/services/event_store/database/unsupported.dart'
    if (dart.library.js_interop) 'package:nostr_notes/services/event_store/database/web.dart'
    if (dart.library.ffi) 'package:nostr_notes/services/event_store/database/native.dart';

final class DbModule extends DiScope {
  const DbModule();

  @override
  void bind(DiStorage di) {
    di.bind<AppDatabase>(
      () => database,
      lifeTime: const LifeTime.single(),
      module: this,
    );
    di.bind<RawEventStore>(
      () => DriftEventStore(dao: NostrEventDao(di.resolve())),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    // DAOs
    di.bind<OutboxDaoInterface>(
      () => OutboxDao(di.resolve()),
      module: this,
      lifeTime: const LifeTime.single(),
    );
  }
}
