import 'package:common/domain/repo/get_classification_repo.dart';
import 'package:drift/drift.dart';
import 'package:common/services/event_store/database/app_database.dart';

import '../tables/note_class_probabilities.dart';

part 'note_class_probabilities_dao.g.dart';

@DriftAccessor(tables: [NoteClassProbabilities])
class NoteClassProbabilitiesDao extends DatabaseAccessor<AppDatabase>
    with _$NoteClassProbabilitiesDaoMixin
    implements GetClassificationRepo {
  NoteClassProbabilitiesDao(super.db);

  /// Upserts classification results for a single event.
  /// Only stores entries where probability >= [minProbability].
  @override
  Future<void> upsertProbabilities(
    String eventId,
    Map<String, double> probabilities, {
    double minProbability = 0.1,
  }) async {
    final rows = probabilities.entries
        .where((e) => e.value >= minProbability)
        .map(
          (e) => NoteClassProbabilitiesCompanion.insert(
            eventId: eventId,
            category: e.key,
            probability: e.value,
          ),
        )
        .toList();

    if (rows.isEmpty) return;

    await batch((b) {
      b.insertAllOnConflictUpdate(noteClassProbabilities, rows);
    });
  }

  /// Returns all categories and probabilities for the given events.
  /// Only entries with probability >= [minProbability] are included.
  @override
  Future<Map<String, Map<String, double>>> getProbabilities(
    Set<String> eventIds, {
    double minProbability = 0.1,
  }) async {
    if (eventIds.isEmpty) return {};

    final rows =
        await (select(noteClassProbabilities)..where(
              (t) =>
                  t.eventId.isIn(eventIds) &
                  t.probability.isBiggerOrEqualValue(minProbability),
            ))
            .get();

    final result = <String, Map<String, double>>{};
    for (final r in rows) {
      (result[r.eventId] ??= {})[r.category] = r.probability;
    }
    return result;
  }

  /// Watches all categories and probabilities for a given event.
  @override
  Stream<Map<String, double>> watchProbabilities(
    String eventId, {
    double minProbability = 0.1,
  }) {
    return (select(noteClassProbabilities)..where(
          (t) =>
              t.eventId.equals(eventId) &
              t.probability.isBiggerOrEqualValue(minProbability),
        ))
        .watch()
        .map((rows) => {for (final r in rows) r.category: r.probability});
  }

  /// Deletes all classification data for a given event.
  Future<void> deleteProbabilities(String eventId) async {
    await (delete(
      noteClassProbabilities,
    )..where((t) => t.eventId.equals(eventId))).go();
  }

  /// Returns event IDs that have a category with probability >= [minProbability].
  Future<List<String>> getEventIdsByCategory(
    String category, {
    double minProbability = 0.1,
  }) async {
    final rows =
        await (select(noteClassProbabilities)
              ..where(
                (t) =>
                    t.category.equals(category) &
                    t.probability.isBiggerOrEqualValue(minProbability),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.probability)]))
            .get();
    return rows.map((r) => r.eventId).toList();
  }
}
