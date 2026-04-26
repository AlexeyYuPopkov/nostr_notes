import 'package:common/services/event_store/database/tables/tables.dart';
import 'package:drift/drift.dart';

/// Minimum probability to store a category classification result.
/// Values below this threshold are considered noise and skipped.
// const kClassificationMinProbability = 0.05;

@DataClassName('NoteClassProbabilityData')
class NoteClassProbabilities extends Table {
  TextColumn get eventId =>
      text().references(NostrEvents, #id, onDelete: KeyAction.cascade)();

  /// Category name (e.g. 'finance', 'work', 'travel')
  TextColumn get category => text()();

  /// Sigmoid probability in range [0, 1].
  /// Only rows with probability >= kClassificationMinProbability are stored.
  RealColumn get probability => real()();

  @override
  Set<Column<Object>> get primaryKey => {eventId, category};
}
