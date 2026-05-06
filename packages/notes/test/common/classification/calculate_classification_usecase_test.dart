import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/database/daos/note_class_probabilities_dao.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/data/ai/classification_repo_impl.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/usecase/calculate_classification_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_classification_usecase.dart';
import '../../../integration_test/di/in_memory_db_module.dart';

void main() {
  late CalculateClassificationUsecase sut;
  late AppDatabase db;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    const InMemoryDbModule().bind(DiStorage.shared);

    db = DiStorage.shared.resolve();

    final getClassificationRepo = NoteClassProbabilitiesDao(db);

    sut = CalculateClassificationUsecase(
      classificationRepo: ClassificationRepoImpl(),
      getClassificationRepo: getClassificationRepo,
      getClassificationUsecase: GetClassificationUsecase(
        getClassificationRepo: getClassificationRepo,
      ),
    );
  });

  tearDown(() async {
    await db.close();
    DiStorage.shared.removeAll();
  });

  group('top category prediction. [useCorrection: true, useModel: true]', () {
    const categoryNotes = {
      'finance':
          'Checked my investment portfolio today. Stock prices \$ dropped '
          'significantly. Considering reallocating budget and reviewing expenses.'
          'I need more \$ to bye eoro and btc, eth',
      // 'journal':
      //     '- Woke up early and had coffee\n'
      //     '- Went for a walk in the park\n'
      //     '- Read a few chapters of my book\n'
      //     '- Reflected on the past week and wrote some thoughts\n'
      //     '- Feeling calm and at peace today',
      'personal':
          'Had a great time with my family this evening. We cooked dinner '
          'together and talked for hours. Feeling happy and grateful.',
      'security':
          'Detected a suspicious login attempt on the server. Rotated API '
          'keys, patched the vulnerability, and enabled two-factor authentication.'
          '7mzJQzCubm0prHP30Fi9',
      'travel':
          'Booked flights to Tokyo for next month. Planning to visit temples, '
          'try local cuisine, and explore the countryside.',
      'work':
          'Fixed a critical bug in the deployment pipeline. Reviewed pull '
          'requests and updated the technical documentation for the new API.',
      'bookmarks': 'https://example.com/page',
    };

    for (final entry in categoryNotes.entries) {
      final expectedCategory = entry.key;
      final content = entry.value;

      test('classifies "$expectedCategory" note correctly', () async {
        final note = Note(
          eventId: 'event-$expectedCategory',
          dTag: 'd-$expectedCategory',
          content: content,
          summary: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final result = await sut.execute(
          note,
          useCorrection: false,
          useModel: true,
        );

        expect(result, isNotEmpty);

        final topCategory = result.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

        expect(
          topCategory,
          expectedCategory,
          reason:
              'Expected top category "$expectedCategory" '
              'but got "$topCategory". Probabilities: $result',
        );
      });
    }
  }, skip: true);

  group('top category prediction. [useCorrection: true, useModel: false]', () {
    const categoryNotes = {
      'finance':
          'Checked my investment portfolio today. Stock prices \$ dropped '
          'significantly. Considering reallocating budget and reviewing expenses.'
          'I need more \$ to bye eoro and btc, eth',
      'journal':
          '## April 25\n\n'
          '- Woke up early and had coffee\n'
          '- Went for a walk in the park\n'
          '- Read a few chapters of my book\n'
          '- Reflected on the past week and wrote some thoughts\n'
          '- Feeling calm and at peace today',
      // 'personal':
      //     'Had a great time with my family this evening. We cooked dinner '
      //     'together and talked for hours. Feeling happy and grateful.',
      'security':
          'Detected a suspicious login attempt on the server. Rotated API '
          'keys, patched the vulnerability, and enabled two-factor authentication.'
          '7mzJQzCubm0prHP30Fi9',
      // 'travel':
      //     'Booked flights to Tokyo for next month. Planning to visit temples, '
      //     'try local cuisine, and explore the countryside.',
      'work':
          'Fixed a critical bug in the deployment pipeline. Reviewed pull '
          'requests and updated the technical documentation for the new API.',
      'bookmarks': 'https://example.com/page',
    };

    for (final entry in categoryNotes.entries) {
      final expectedCategory = entry.key;
      final content = entry.value;

      test('classifies "$expectedCategory" note correctly', () async {
        final note = Note(
          eventId: 'event-$expectedCategory',
          dTag: 'd-$expectedCategory',
          content: content,
          summary: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final result = await sut.execute(
          note,
          useCorrection: true,
          useModel: false,
        );

        expect(result, isNotEmpty);

        final topCategory = result.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

        expect(
          topCategory,
          expectedCategory,
          reason:
              'Expected top category "$expectedCategory" '
              'but got "$topCategory". Probabilities: $result',
        );
      });
    }
  }, skip: true);
}
