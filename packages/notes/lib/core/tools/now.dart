class Now {
  const Now();
  static const instance = Now();

  DateTime now() => DateTime.now();
}
