import 'dart:developer' as dev;
import 'dart:math';

import 'package:common/domain/repo/get_classification_repo.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/repo/classification_corrections.dart';
import 'package:nostr_notes/auth/domain/repo/classification_repo.dart';
import 'package:nostr_notes/auth/domain/usecase/get_classification_usecase.dart';

final class CalculateClassificationUsecase {
  static const minProbability = 0.1;
  static const _correctionThreshold = 0.5;
  final ClassificationRepo _classificationRepo;
  final GetClassificationRepo _noteClassificationRepo;
  final ClassificationCorrections _corrections;

  const CalculateClassificationUsecase({
    required ClassificationRepo classificationRepo,
    required GetClassificationRepo getClassificationRepo,
    required GetClassificationUsecase getClassificationUsecase,
    ClassificationCorrections corrections = const ClassificationCorrections(),
  }) : _classificationRepo = classificationRepo,
       _noteClassificationRepo = getClassificationRepo,
       _corrections = corrections;

  Future<Map<String, double>> execute(
    Note note, {
    bool useCorrection = false,
    bool useModel = true,
    // bool force = true,
  }) async {
    try {
      // if (!force) {
      //   final existing = await _getClassificationUsecase.execute({
      //     note.eventId,
      //   });
      //   if (existing.containsKey(note.eventId) &&
      //       existing[note.eventId]!.isNotEmpty) {
      //     dev.log(
      //       'Using existing classification for event ${note.eventId}',
      //       name: 'Classification',
      //     );
      //     return existing[note.eventId]!;
      //   }
      // }

      final eventId = note.eventId;
      Map<String, double> classification = {};

      if (useModel && useCorrection) {
        // Модель + коррекция
        final raw = await _classificationRepo.classify(note.content);
        classification = _applyCorrections(note.content, raw);
      } else if (useModel && !useCorrection) {
        // Только модель
        classification = await _classificationRepo.classify(note.content);
      } else if (!useModel && useCorrection) {
        // Только коррекция (без модели) — равномерный prior для всех категорий
        const categories = [
          'security',
          'finance',
          'work',
          'journal',
          'bookmarks',
        ];
        final uniformWeight = 1.0 / categories.length;
        final uniformProbs = {for (final c in categories) c: uniformWeight};
        classification = _applyCorrections(note.content, uniformProbs);
      } else {
        // Оба false — пустой результат
        assert(false, 'Both useModel and useCorrection cannot be false');
        classification = {};
      }

      await _noteClassificationRepo.upsertProbabilities(
        eventId,
        classification,
        minProbability: minProbability,
      );
      dev.log(
        'Classification: ${(classification..removeWhere((_, val) => val < 0.1)).toString()}',
        name: 'Classification',
      );
      return classification;
    } catch (e) {
      dev.log('Error during classification: $e', name: 'Classification');
      return {};
    }
  }

  Map<String, double> _applyCorrections(
    String text,
    Map<String, double> probs,
  ) {
    final scores = <String, double>{
      'security': _corrections.securityScore(text),
      'finance': _corrections.financeScore(text),
      'work': _corrections.workScore(text),
      'journal': _corrections.journalScore(text),
      'bookmarks': _corrections.bookmarksScore(text),
    };

    final keys = probs.keys.toList();
    final values = keys.map((k) {
      final score = scores[k];
      if (score != null && score >= _correctionThreshold) {
        return max(probs[k]!, score);
      }
      return probs[k]!;
    }).toList();

    // Renormalize via softmax to keep sum == 1
    final maxV = values.reduce(max);
    final exps = values.map((v) => exp(v - maxV)).toList();
    final total = exps.fold(0.0, (s, v) => s + v);

    final result = {
      for (int i = 0; i < keys.length; i++) keys[i]: exps[i] / total,
    };

    return result;
  }
}
