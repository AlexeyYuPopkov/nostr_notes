import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/password_strength_usecase.dart';

void main() {
  const sut = PasswordStrengthUsecase();

  group('PasswordStrengthUsecase', () {
    test('danger password', () {
      expect(sut.execute(''), PasswordStrength.danger);
      expect(sut.execute('cat'), PasswordStrength.danger);
      expect(sut.execute('correct'), PasswordStrength.danger);
      expect(sut.execute('password'), PasswordStrength.danger);
      expect(sut.execute('12345678'), PasswordStrength.danger);
      // Mixed classes don't save a password that's too short.
      expect(sut.execute('Ab1'), PasswordStrength.danger);
    });

    test('weak password', () {
      expect(sut.execute('Pass1234'), PasswordStrength.weak);
      expect(sut.execute('pass1234'), PasswordStrength.weak);
      expect(sut.execute('Pass123'), PasswordStrength.weak);
    });

    test('good password', () {
      expect(sut.execute('Pass@1234'), PasswordStrength.good);
      expect(sut.execute('Passw0rd@12'), PasswordStrength.good);
      expect(sut.execute('CorrectHors!'), PasswordStrength.good);
    });

    test('strong password', () {
      const passList = [
        'Xk8mQw2Zt5L#7',
        r'aB3$fG7!kL9@qR2#',
        r'Zx9#Qm2$Wv7@Nt4!',
        r'Qw3rTy#Zx9$Lp2@Mn7!',
        'Turkey?Hedgehog*71',
        'Meteor@Almond@15',
        'Deer?Meadow&91',
        r'Jasmine&Sparrow$24',
        'Fern%Salmon&99',
        r'Pony!Robin#93',
        'Swan*Whirlwind!67',
        'Icicle?Shrew#99',
        r'Zebra*Titanium&68',
        'Bronze?Clover&32',
      ];

      for (final password in passList) {
        expect(
          sut.execute(password),
          PasswordStrength.strong,
          reason: password,
        );
      }
    });
  });
}
