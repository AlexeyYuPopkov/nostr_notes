import 'dart:math';

enum PassStyle { dicewareStyle, randomStyle }

final class GenPassUsecase {
  const GenPassUsecase();

  String execute(PassStyle style) {
    switch (style) {
      case PassStyle.dicewareStyle:
        return _generateDicewarePassword();
      case PassStyle.randomStyle:
        return _generateRandomPassword();
    }
  }

  static const _words = [
    'Enot',
    'Tiger',
    'Losos',
    'Volk',
    'Bober',
    'Sova',
    'Lisa',
    'Medved',
    'Zebra',
    'Panda',
    'Yastreb',
    'Kotik',
    'Barsuk',
    'Orel',
    'Vydra',
    'Rys',
    'Los',
    'Zayac',
    'Belka',
    'Kaban',
  ];

  static const _specials = '@#\$%&*!?';

  String _generateDicewarePassword({
    int wordCount = 2,
    bool addNumber = true,
    bool addSpecial = true,
  }) {
    final rand = Random.secure();

    final parts = List.generate(
      wordCount,
      (_) => _words[rand.nextInt(_words.length)],
    );

    var password = parts.join(
      addSpecial ? _specials[rand.nextInt(_specials.length)] : '',
    );

    if (addNumber) {
      final number = rand.nextInt(90) + 10; // 10..99
      password +=
          (addSpecial ? _specials[rand.nextInt(_specials.length)] : '') +
          number.toString();
    }

    return password;
  }

  String _generateRandomPassword({
    int length = 16,
    bool useUpper = true,
    bool useLower = true,
    bool useDigits = true,
    bool useSpecial = true,
  }) {
    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const digits = '0123456789';
    const special = '!@#\$%^&*()-_=+[]{}<>?';

    String chars = '';
    if (useUpper) chars += upper;
    if (useLower) chars += lower;
    if (useDigits) chars += digits;
    if (useSpecial) chars += special;

    if (chars.isEmpty) {
      throw ArgumentError('Нужно выбрать хотя бы один тип символов');
    }

    final rand = Random.secure();
    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }
}
