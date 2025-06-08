import 'package:nostr_notes/common/domain/model/error/app_error.dart';
import 'package:nostr_notes/common/domain/model/session/user_keys.dart';

abstract class KeyToolRepository {
  UserKeys getUserKeys({required String? nsec});
}

abstract class NsecError extends AppError {
  const NsecError({required super.reason});
}

final class InvalidNsecError extends NsecError {
  const InvalidNsecError() : super(reason: 'Invalid NSEC key format');
}

final class InvalidPubkeyError extends NsecError {
  const InvalidPubkeyError() : super(reason: 'Invalid Public');
}
