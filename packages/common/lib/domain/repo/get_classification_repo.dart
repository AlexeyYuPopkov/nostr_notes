abstract interface class GetClassificationRepo {
  Future<void> upsertProbabilities(
    String eventId,
    Map<String, double> probabilities, {
    double minProbability = 0.2,
  });
  Future<Map<String, Map<String, double>>> getProbabilities(
    Set<String> eventIds, {
    double minProbability = 0.2,
  });
  Stream<Map<String, double>> watchProbabilities(
    String eventId, {
    double minProbability = 0.2,
  });
}
