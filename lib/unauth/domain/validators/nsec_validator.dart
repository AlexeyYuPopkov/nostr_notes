import 'package:nostr_notes/common/domain/error/app_error.dart';

abstract interface class NsecValidator {
  const NsecValidator();

  InvalidNsecError? validate(String? nsecKey);
}

final class InvalidNsecError extends AppError {
  const InvalidNsecError() : super(reason: 'Invalid NSEC key format');
}
