import 'package:chat/auth/chat/domain/usecase/search_contacts_fetch_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/search_contacts_get_usecase.dart';
import 'package:common/domain/model/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// Usage: And a contact named {'Alice'} can be found
///
/// Relays answer at once; the store holds a single profile named [name].
Future<void> aContactNamedCanBeFound(WidgetTester tester, String name) async {
  GetIt.I.unregister<SearchContactsFetchUsecase>();
  GetIt.I.registerSingleton<SearchContactsFetchUsecase>(
    const _RelaysAnswerAtOnce(),
  );

  GetIt.I.unregister<SearchContactsGetUsecase>();
  GetIt.I.registerSingleton<SearchContactsGetUsecase>(
    _StoredProfiles([
      User(
        pubkey:
            '82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2',
        name: name,
      ),
    ]),
  );
}

final class _RelaysAnswerAtOnce implements SearchContactsFetchUsecase {
  const _RelaysAnswerAtOnce();

  @override
  Future<void> execute(String query) async {}
}

final class _StoredProfiles implements SearchContactsGetUsecase {
  final List<User> _users;

  const _StoredProfiles(this._users);

  @override
  Stream<List<User>> execute(String query) {
    final normalized = query.trim().toLowerCase();
    return Stream.value([
      for (final user in _users)
        if ((user.name ?? '').toLowerCase().contains(normalized)) user,
    ]);
  }
}
