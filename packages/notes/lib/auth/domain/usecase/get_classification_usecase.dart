import 'package:common/domain/repo/get_classification_repo.dart';
import 'package:nostr_notes/auth/domain/model/category.dart';

final class GetClassificationUsecase {
  static const minProbability = 0.1;

  final GetClassificationRepo _getClassificationRepo;

  const GetClassificationUsecase({
    required GetClassificationRepo getClassificationRepo,
  }) : _getClassificationRepo = getClassificationRepo;

  Future<Map<String, Map<String, double>>> execute(Set<String> eventIds) {
    return _getClassificationRepo.getProbabilities(eventIds);
  }

  Future<Map<String, CategoryType>> executeAsType(Set<String> eventIds) {
    return execute(
      eventIds,
    ).then((probs) => probs.map((k, v) => MapEntry(k, v.getCategoryType())));
  }

  Stream<Category> getSymbol(String eventId) {
    return _getClassificationRepo
        .watchProbabilities(eventId, minProbability: minProbability)
        .map((probs) => probs.getSymbol());
  }
}

extension on Map<String, double> {
  Category getSymbol() {
    return isEmpty
        ? Category.fromCategoryType(.other)
        : Category.fromCategoryType(getCategoryType());
  }

  CategoryType getCategoryType() {
    if (isEmpty) {
      return .other;
    }

    final maxEntry = entries.reduce((a, b) => a.value > b.value ? a : b);
    final category = maxEntry.key;
    return CategoryType.fromString(category);
  }
}
