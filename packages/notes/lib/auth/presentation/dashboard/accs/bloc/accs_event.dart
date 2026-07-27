import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';

sealed class AccsEvent extends Equatable {
  const AccsEvent();

  /// Subscribes to the local login-items stream and triggers a relay sync.
  const factory AccsEvent.initial() = InitialEvent;

  /// New decrypted items arrived from the local store.
  const factory AccsEvent.itemsUpdated(List<LoginItem> items) =
      ItemsUpdatedEvent;

  /// Re-fetches login items from relays without re-subscribing (refresh /
  /// app-resume).
  const factory AccsEvent.sync() = SyncEvent;

  const factory AccsEvent.search(String query) = SearchEvent;

  const factory AccsEvent.error(Object error) = ErrorEvent;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends AccsEvent {
  const InitialEvent();
}

final class ItemsUpdatedEvent extends AccsEvent {
  final List<LoginItem> items;
  const ItemsUpdatedEvent(this.items);
  @override
  List<Object?> get props => [items];
}

final class SyncEvent extends AccsEvent {
  const SyncEvent();
}

final class SearchEvent extends AccsEvent {
  final String query;
  const SearchEvent(this.query);
  @override
  List<Object?> get props => [query];
}

final class ErrorEvent extends AccsEvent {
  final Object error;
  const ErrorEvent(this.error);
  @override
  List<Object?> get props => [error];
}
