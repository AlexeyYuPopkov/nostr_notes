import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/unauth/data/validators/nsec_validator_impl.dart';
import 'package:nostr_notes/unauth/domain/validators/nsec_validator.dart';

void main() {
  const NsecValidator validator = NsecValidatorImpl();

  group('NsecValidator', () {
    test('invalid nsec', () {
      expect(validator.validate(null), isA<InvalidNsecError>());
      expect(validator.validate(''), isA<InvalidNsecError>());
      expect(validator.validate('abc1234567'), isA<InvalidNsecError>());
      expect(validator.validate('nsec'), isA<InvalidNsecError>());
    });

    test('valid nsec', () {
      const validNsec =
          'nsec1jx4lljfh44rygj4mrqg2rdn8l32enhp56e753htfgavzt945330sg5n0xz';
      expect(validator.validate(validNsec), isNull);
    });
  });
}
