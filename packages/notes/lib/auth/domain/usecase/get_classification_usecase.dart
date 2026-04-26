import 'package:common/domain/repo/get_classification_repo.dart';
import 'package:nostr_notes/auth/domain/model/category.dart';

final class GetClassificationUsecase {
  static const minProbability = 0.3;

  final GetClassificationRepo _getClassificationRepo;

  const GetClassificationUsecase({
    required GetClassificationRepo getClassificationRepo,
  }) : _getClassificationRepo = getClassificationRepo;

  Future<Map<String, Map<String, double>>> execute(Set<String> eventIds) {
    return _getClassificationRepo.getProbabilities(eventIds);
  }

  // Future<Map<String, String>> getSymbols(Set<String> eventIds) async {
  //   final futureProbs = await _getClassificationRepo.getProbabilities(
  //     eventIds,
  //     minProbability: minProbability,
  //   );

  //   final result = <String, String>{};

  //   for (final entry in futureProbs.entries) {
  //     final eventId = entry.key;
  //     final probs = entry.value;

  //     if (probs.isEmpty) {
  //       continue;
  //     }

  //     result[eventId] = probs.getSymbol();
  //   }

  //   return result;
  // }

  Stream<Category> getSymbol(String eventId) {
    return _getClassificationRepo
        .watchProbabilities(eventId, minProbability: minProbability)
        .map((probs) => probs.getSymbol());
  }
}

extension on Map<String, double> {
  Category getSymbol() {
    if (isEmpty) {
      return Category.from(null);
    }

    final maxEntry = entries.reduce((a, b) => a.value > b.value ? a : b);
    final category = maxEntry.key;
    return Category.from(category);
  }
}
