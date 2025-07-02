mixin DateTimeHelper {}

extension DateTimeHelperExtension on DateTime {
  int toSecondsSinceEpoch() {
    return millisecondsSinceEpoch * 1000;
  }
}
