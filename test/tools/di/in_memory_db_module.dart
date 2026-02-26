import 'dart:ffi';
import 'dart:io';

import 'package:di_storage/di_storage.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:nostr_notes/services/event_store/database/app_database.dart';
import 'package:nostr_notes/services/event_store/database/daos/nostr_event_dao.dart';
import 'package:nostr_notes/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:nostr_notes/services/event_store/drift_event_store.dart';
import 'package:nostr_notes/services/event_store/raw_event_store.dart';
import 'package:sqlite3/open.dart';

void _ensureSqlite3() {
  if (Platform.isMacOS || Platform.isLinux) {
    open.overrideFor(OperatingSystem.macOS, () {
      return DynamicLibrary.open('/usr/lib/libsqlite3.dylib');
    });
    open.overrideFor(OperatingSystem.linux, () {
      return DynamicLibrary.open('libsqlite3.so');
    });
  }
}

final class InMemoryDbModule extends DiScope {
  const InMemoryDbModule();

  @override
  void bind(DiStorage di) {
    _ensureSqlite3();
    di.bind<AppDatabase>(
      () => AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory())),
      module: this,
      lifeTime: const LifeTime.single(),
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
