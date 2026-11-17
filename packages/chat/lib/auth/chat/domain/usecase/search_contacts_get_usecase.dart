import 'package:common/domain/model/user.dart';

abstract interface class SearchContactsGetUsecase {
  /// Stored profiles (kind 0) matching [query] — an exact match when [query]
  /// is an npub or a hex pubkey (a bare `User` if no profile is stored),
  /// otherwise a full-text match. Emits now and on every store change; `[]`
  /// for a blank query.
  Stream<List<User>> execute(String query);
}
