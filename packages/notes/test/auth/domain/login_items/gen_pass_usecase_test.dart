import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/gen_pass_usecase.dart';

void main() {
  const sut = GenPassUsecase();

  group('GenPassUsecase.execute(dicewareStyle)', () {
    // word + special + word + special + 2-digit number, e.g. "Fox#Owl!42".
    final dicewarePattern = RegExp(
      r'^[A-Za-z]+[@#$%&*!?][A-Za-z]+[@#$%&*!?]\d{2}$',
    );

    test('check if unique', () {
      final passwords = List.generate(
        50,
        (_) => sut.execute(PassStyle.dicewareStyle),
      );

      for (final password in passwords) {
        expect(password, matches(dicewarePattern), reason: password);
      }

      final uniqueLegth = passwords.toSet().length;
      final totalLength = passwords.length;
      expect(uniqueLegth, greaterThan(1));
      expect(totalLength, uniqueLegth);
    });
  });

  group('GenPassUsecase.execute(randomStyle)', () {
    const allowedChars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        'abcdefghijklmnopqrstuvwxyz'
        '0123456789'
        r'!@#$%^&*()-_=+[]{}<>?';

    test('check if unique', () {
      final passwords = List.generate(
        50,
        (_) => sut.execute(PassStyle.randomStyle),
      );

      for (final password in passwords) {
        expect(password, hasLength(16));
        expect(
          password.split('').every(allowedChars.contains),
          isTrue,
          reason: password,
        );
      }

      final uniqueLegth = passwords.toSet().length;
      final totalLength = passwords.length;
      expect(uniqueLegth, greaterThan(1));
      expect(totalLength, uniqueLegth);
    });
  });
}
