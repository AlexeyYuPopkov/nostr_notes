import 'dart:math';

enum PasswordStrength { danger, weak, good, strong }

/// Estimates password strength from character-class diversity and length —
/// a standard, cheap heuristic (roughly what most password managers show),
/// not a dictionary/pattern-aware analysis. It scores multi-word/diceware
/// passwords generously (mixed case + digits + specials read as a large
/// pool), even though their true entropy is bounded by the word list size,
/// not the character set — good enough for a UI hint, not a security audit.
final class PasswordStrengthUsecase {
  const PasswordStrengthUsecase();

  static final _lower = RegExp('[a-z]');
  static final _upper = RegExp('[A-Z]');
  static final _digit = RegExp('[0-9]');
  static final _special = RegExp(r'[^a-zA-Z0-9]');

  // Character-class pool sizes: how many distinct values one character could
  // take once we know which classes are present in the password.
  static const _lowerCasePoolSize = 26; // a-z
  static const _upperCasePoolSize = 26; // A-Z
  static const _digitPoolSize = 10; // 0-9
  // Everything else in the printable ASCII range (95 characters, 0x20–0x7E:
  // space through `~`) that isn't already counted above — punctuation,
  // symbols, space: 95 - _lowerCasePoolSize - _upperCasePoolSize -
  // _digitPoolSize = 33.
  static const _specialCharPoolSize = 33;

  // Minimum entropy (bits) to reach each tier, i.e. the tier is
  // `bits >= tierThresholdBits && bits < nextTierThresholdBits`. Not derived
  // from a single external standard — calibrated against the worked
  // examples in password_strength_usecase_test.dart, so adjust threshold and
  // tests together.
  static const _weakThresholdBits = 40;
  static const _goodThresholdBits = 55;
  static const _strongThresholdBits = 80;

  PasswordStrength execute(String password) {
    if (password.isEmpty) {
      return PasswordStrength.danger;
    }

    final bits = _entropyBits(password);
    if (bits < _weakThresholdBits) return PasswordStrength.danger;
    if (bits < _goodThresholdBits) return PasswordStrength.weak;
    if (bits < _strongThresholdBits) return PasswordStrength.good;
    return PasswordStrength.strong;
  }

  double _entropyBits(String password) {
    var poolSize = 0;
    if (_lower.hasMatch(password)) poolSize += _lowerCasePoolSize;
    if (_upper.hasMatch(password)) poolSize += _upperCasePoolSize;
    if (_digit.hasMatch(password)) poolSize += _digitPoolSize;
    if (_special.hasMatch(password)) poolSize += _specialCharPoolSize;

    if (poolSize == 0) {
      return 0;
    }
    return password.length * (log(poolSize) / log(2));
  }
}
