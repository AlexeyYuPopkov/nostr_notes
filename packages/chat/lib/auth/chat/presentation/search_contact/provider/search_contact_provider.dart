import 'dart:async';

import 'package:chat/auth/chat/domain/usecase/search_contacts_fetch_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/search_contacts_get_usecase.dart';
import 'package:common/domain/model/user.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

import 'search_contact_data.dart';
import 'search_contact_state.dart';

part 'search_contact_provider.g.dart';

typedef _RelaysOutcome = ({bool answered, Object? error});
typedef _SearchSnapshot = ({List<User> users, _RelaysOutcome relays});

@riverpod
final class SearchContactProvider extends _$SearchContactProvider {
  static const debounceDuration = Duration(milliseconds: 400);
  static const _storeThrottle = Duration(milliseconds: 300);

  late final SearchContactsFetchUsecase _fetchUsecase = GetIt.I.get();
  late final SearchContactsGetUsecase _getUsecase = GetIt.I.get();
  final _queries = PublishSubject<String>();

  SearchContactData get _data => state.data;

  @override
  SearchContactState build() {
    final subscription = _queries
        .distinct()
        // Clearing the field cancels a pending search at once; typing waits
        // until the user pauses.
        .debounce(
          (query) => query.isEmpty
              ? Stream<void>.value(null)
              : TimerStream<void>(null, debounceDuration),
        )
        .switchMap(_search)
        .throttleTime(_storeThrottle, trailing: true)
        .listen(_onSnapshot, onError: _onError);

    ref.onDispose(() {
      subscription.cancel();
      _queries.close();
    });

    return SearchContactCommon(data: SearchContactData.initial());
  }

  void onQueryChanged(String rawQuery) {
    final query = rawQuery.trim();
    if (query == _data.query) {
      return;
    }

    state = query.isEmpty
        ? SearchContactCommon(
            data: _data.copyWith(query: '', users: []),
          )
        : SearchContactLoading(data: _data.copyWith(query: query));
    _queries.add(query);
  }

  /// The store is the source of truth: users always come from
  /// [SearchContactsGetUsecase]; [SearchContactsFetchUsecase] only fills the
  /// store and tells whether the relays have answered yet.
  Stream<_SearchSnapshot> _search(String query) {
    final relays = Stream.fromFuture(_fetchUsecase.execute(query))
        .map<_RelaysOutcome>((_) => (answered: true, error: null))
        .onErrorReturnWith((error, _) => (answered: true, error: error))
        .startWith((answered: false, error: null));

    return Rx.combineLatest2(
      _getUsecase.execute(query),
      relays,
      (users, relays) => (users: users, relays: relays),
    );
  }

  void _onSnapshot(_SearchSnapshot snapshot) {
    final data = _data.copyWith(users: snapshot.users);
    final relaysError = snapshot.relays.error;

    if (snapshot.users.isEmpty && !snapshot.relays.answered) {
      state = SearchContactLoading(data: data);
    } else if (relaysError != null) {
      state = SearchContactError(data: data, error: relaysError);
    } else {
      state = SearchContactCommon(data: data);
    }
  }

  void _onError(Object error) {
    state = SearchContactError(data: _data, error: error);
  }
}
