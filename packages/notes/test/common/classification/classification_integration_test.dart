import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/database/daos/note_class_probabilities_dao.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/data/ai/classification_repo_impl.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/usecase/calculate_classification_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_classification_usecase.dart';
import '../../../integration_test/di/in_memory_db_module.dart';

void main() {
  late CalculateClassificationUsecase sut1;
  late GetClassificationUsecase sut2;
  late NoteClassProbabilitiesDao getClassificationRepo;
  late AppDatabase db;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    const InMemoryDbModule().bind(DiStorage.shared);

    db = DiStorage.shared.resolve();

    getClassificationRepo = NoteClassProbabilitiesDao(db);

    sut2 = GetClassificationUsecase(
      getClassificationRepo: getClassificationRepo,
    );

    sut1 = CalculateClassificationUsecase(
      classificationRepo: ClassificationRepoImpl(),
      getClassificationRepo: getClassificationRepo,
      getClassificationUsecase: sut2,
    );
  });

  tearDown(() async {
    await db.close();
    DiStorage.shared.removeAll();
  });

  test('calculate saves classification and get returns it', () async {
    const eventId = 'test-event-id-001';
    final note = Note(
      eventId: eventId,
      dTag: 'd-tag',
      content: 'Bought some stocks today and checked my portfolio performance.',
      summary: '',
      createdAt: DateTime.now(),
      initAt: DateTime.now(),
    );

    // Calculate and persist classification
    final calculated = await sut1.execute(note);

    expect(calculated, isNotEmpty);

    // Retrieve and verify saved probabilities
    final result = await sut2.execute({eventId});

    expect(result, contains(eventId));
    expect(result[eventId], isNotEmpty);

    // Verify categories from calculate match stored ones
    for (final entry in result[eventId]!.entries) {
      expect(calculated, contains(entry.key));
    }

    final category = await sut2.getSymbol(eventId).first;

    expect(category.symbol, isNotEmpty);
    expect(Label.categorySymbols.containsValue(category.symbol), isTrue);
  }, skip: true);

  test('get returns empty map for unknown event', () async {
    final result = await sut2.execute({'non-existent-id'});
    expect(result['non-existent-id'], anyOf(isNull, isEmpty));
  }, skip: true);

  test('calculate for multiple notes stores independently', () async {
    final notes = [
      Note(
        eventId: 'event-001',
        dTag: 'd1',
        content: 'Traveling to Japan next month, booking flights.',
        summary: '',
        createdAt: DateTime.now(),
        initAt: DateTime.now(),
      ),
      Note(
        eventId: 'event-002',
        dTag: 'd2',
        content: 'Fixed a critical security vulnerability in the codebase.',
        summary: '',
        createdAt: DateTime.now(),
        initAt: DateTime.now(),
      ),
    ];

    for (final note in notes) {
      await sut1.execute(note);
    }

    final result = await sut2.execute({'event-001', 'event-002'});

    expect(result['event-001'], isNotEmpty);
    expect(result['event-002'], isNotEmpty);
  }, skip: true);
}
