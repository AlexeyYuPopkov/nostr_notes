abstract interface class ClassificationRepo {
  Future<Map<String, double>> classify(String text);
}
