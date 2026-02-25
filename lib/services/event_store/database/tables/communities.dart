// common/infrastructure/storage/drift/reactions_table.dart

import 'package:drift/drift.dart';

@DataClassName('CommunityData')
class Communities extends Table {
  TextColumn get id => text()();

  /// Pubkey of the user who reacted.
  TextColumn get reactorPubKey => text()();

  /// Event id that this reaction targets (from 'e' tag).
  TextColumn get targetEventId => text()();

  /// Reaction content, e.g. '+', '❤️', '👎', etc.
  TextColumn get content => text()();

  /// created_at (seconds since epoch, UTC)
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
