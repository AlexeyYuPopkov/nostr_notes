import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/nostr_event_dao.dart';
import 'daos/outbox_dao.dart';
import 'tables/nostr_event_relays.dart';
import 'tables/nostr_events.dart';
import 'tables/nostr_tags.dart';
import 'tables/outbox_events.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [NostrEvents, NostrTags, NostrEventRelays, OutboxEvents],
  daos: [NostrEventDao, OutboxDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  AppDatabase.forTesting(DatabaseConnection super.connection);

  @override
  int get schemaVersion => 2;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'event_store',
      native: const DriftNativeOptions(),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  // @override
  // MigrationStrategy get migration {
  //   return MigrationStrategy(
  //     onCreate: (m) async {
  //       await m.createAll();
  //     },
  //     onUpgrade: (m, from, to) async {
  //       if (from < 2) {
  //         // Add outbox_events table for SQL-first Nostr publishing
  //         await m.createTable(outboxEvents);
  //       }
  //     },
  //     beforeOpen: (details) async {
  //       /// Migrate broken follow notifications
  //       await _fixBrokenNotificationIds(this);
  //     },
  //   );
  // }
}
