import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/services/event_store/database/app_database.dart';

AppDatabase get database => AppConfig.kUsesInMemoryStorage
    ? AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()))
    : AppDatabase();
