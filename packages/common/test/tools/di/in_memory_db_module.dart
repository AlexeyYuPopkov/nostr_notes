import 'package:di_storage/di_storage.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/database/daos/nostr_event_dao.dart';
import 'package:common/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:common/services/event_store/drift_event_store.dart';
import 'package:common/services/event_store/raw_event_store.dart';
// import 'package:sqlite3/open.dart';

// void _ensureSqlite3() {
//   if (Platform.isMacOS || Platform.isLinux) {
//     open.overrideFor(OperatingSystem.macOS, () {
//       return DynamicLibrary.open('/usr/lib/libsqlite3.dylib');
//     });
//     open.overrideFor(OperatingSystem.linux, () {
//       return DynamicLibrary.open('libsqlite3.so');
//     });
//   }
// }

/// Reads `.instance` off [wrapped] via dynamic dispatch and returns it if
/// it's a [T] — used to unwrap di_storage's internal (non-exported)
/// `DiStorageEntry` without depending on its type. Returns null if
/// [wrapped] has no `.instance` getter or it isn't a [T].
T? _tryGetInstance<T>(dynamic wrapped) {
  try {
    final instance = wrapped.instance;
    return instance is T ? instance : null;
  } catch (_) {
    return null;
  }
}

final class InMemoryDbModule extends DiScope {
  const InMemoryDbModule();

  @override
  void bind(DiStorage di) {
    // _ensureSqlite3();
    di.bind<AppDatabase>(
      () => AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory())),
      module: this,
      lifeTime: const LifeTime.single(),
      // Without this, nothing ever closes the in-memory database between
      // tests — each test's setUp binds a fresh AppDatabase, and drift logs
      // a "database class created multiple times" leak warning starting
      // from the second test in any file/run that never disposes the
      // previous one.
      //
      // di_storage 2.0.1 is inconsistent about what `onRemove` receives:
      // DiStorage.removeScope passes the resolved instance directly, but
      // DiStorage.remove/removeAll (what most tests' tearDown actually
      // calls) pass the internal DiStorageEntry wrapper instead — which
      // isn't part of di_storage's public API, so it can't be type-checked
      // here. Handle both shapes dynamically.
      onRemove: (removed) {
        final db = removed is AppDatabase
            ? removed
            : _tryGetInstance<AppDatabase>(removed);
        db?.close();
      },
    );

    di.bind<RawEventStore>(
      () => DriftEventStore(dao: NostrEventDao(di.resolve())),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    di.bind<OutboxDaoInterface>(
      () => di.resolve<AppDatabase>().outboxDao,
      module: this,
      lifeTime: const LifeTime.single(),
    );
  }
}
