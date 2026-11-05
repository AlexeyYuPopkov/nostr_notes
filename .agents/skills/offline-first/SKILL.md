---
name: offline-first
description: Project data-flow rules for Nostr events — the UI renders only what is in the local event store (drift, `RawEventStore`), relay traffic only fills that store, and publishing goes store + outbox first. Use when adding a screen or state holder that shows Nostr data, writing a `FetchX`/`GetX` usecase pair, loading profiles/notes/messages from relays, publishing or editing an event, or testing any of these (packages/notes, packages/chat, packages/common).
---

# Offline-first: the store is the source of truth

The UI never renders events straight from a relay. Relays fill the local store; the UI watches the store. So a cold start shows cached data instantly, works offline, and every source of change (relay, local edit, another screen) reaches the UI through one path.

Reference implementation: `NotesListBloc` (`packages/notes/lib/auth/presentation/dashboard/notes/bloc/notes_list_bloc.dart`) with `FetchNotesUsecase` + `GetNotesUsecase`.

## Reading: a `FetchX` + `GetX` pair

| | `FetchX` — relays → store | `GetX` — store → UI |
|---|---|---|
| Example | `FetchNotesUsecase` | `GetNotesUsecase` / `GetNotesUsecaseImpl` |
| Does | Sends the REQ, `upsert`s every received event into `RawEventStore` | `RawEventStore.watchEvents(RawEventQuery(...))`, maps/filters/decrypts to domain models |
| Returns | A stream whose **lifetime is the REQ**: listening opens it, cancelling closes it (`doOnCancel(() => repo.closeRequest(id))`). Its data is not used for UI | `Stream<List<Model>>` that emits stored data immediately, then on every store change. Optionally `executeAsync()` for a one-shot read |
| Relays | Follows `RelaysListRepo.relaysListStream` with `switchMap`: a relay-list change re-sends the REQ and closes the old one | Knows nothing about relays |
| Errors | Network errors mapped to a typed `AppError` (`FetchNotesUsecaseNetworkError`) | Domain errors (e.g. decryption) |

The state holder — a Bloc in notes, a Riverpod notifier in chat — subscribes to **both** and keeps both subscriptions for as long as the screen lives:

```dart
_fetchSubscription = _fetchNotesUsecase
    .execute(const FetchNotesUsecaseParams.userNotes())
    .listen((_) {}, onError: (e) => add(NotesListEvent.error(error: e)));

_getSubscription = _getNotesUsecase
    .execute()
    .throttleTime(Durations.medium2, trailing: true)
    .listen((notes) => add(NotesListEvent.getNotes(notes: notes)));
```

Rules:
- State comes **only** from `GetX`. `FetchX` output is ignored except for its errors.
- A `FetchX` error is shown alongside the stored data — never replace the list with an error screen while the store has data.
- The loading state lasts until the first `GetX` emission (or a short timeout for an empty store), not until relays answer — EOSE may never come offline.
- Throttle `GetX` (`throttleTime(..., trailing: true)`): a relay burst means many store writes.
- Mapping, filtering of deleted events (kind 5) and decryption belong in `GetXImpl`, not in the UI. Heavy per-emission work uses `exhaustMap`/`asyncMap` there.
- Pull-to-refresh / app resume re-creates both subscriptions; it doesn't fetch "into" the UI.

**Single-item variant** — when one usecase is simpler than a pair, merge the two directions inside it, as `GetUserUsecaseImpl` (`packages/notes/lib/common/data/usecases/get_user_usecase_impl.dart`) does for a kind 0 profile: `Rx.merge([store.watchEvents(...), Stream.fromFuture(_refresh()).ignoreElements()])`, where `_refresh` skips the network while the stored event is fresher than `_staleAfter` and upserts only a newer `createdAt`.

**Not offline-first** — one-off remote queries whose results are not rendered from the store, such as people search (`SearchContactsUsecaseImpl` in chat), may return relay results directly. As soon as such data is shown elsewhere (a chat header showing that profile), upsert it and read it through a `GetX`.

## Writing: store + outbox first

1. Build and sign the event.
2. In the repository: `await eventStore.upsert([event]);` then `await outboxDao.insert(eventId: event.id);` (`NotesRepositoryImpl`). The UI updates right away through the existing `GetX` stream — no optimistic state in the state holder.
3. `OutboxPublisher` watches the outbox table and publishes in the background. **A row exists iff the event still has to reach relays**: deleted on success, kept and retried with backoff on failure. Don't add "sent/pending" flags; read pending state from the outbox (`GetPendingUsecase`).
4. Editing a replaceable/addressable event (same `d` tag): remove the previous version's undelivered outbox rows (`outboxDao.removeUndeliveredByEventIds`) before inserting the new one, so a stale version is never published after the new one.
5. Only `OutboxPublisher` publishes user data. The one exception is a flow that must know the delivery result *before* wiping local data — account deletion publishes its kind 5 directly via `NostrPublisher` (`NotesRepositoryImpl`, deletion of all notes), since the outbox would be cleared with everything else.

## Testing

- Test through behaviour: an integration test of the `FetchXImpl` + `GetXImpl` pair, or a widget/BDD test of the whole screen. The Bloc/Riverpod provider is covered indirectly by the screen test, not by its own unit test.
- **Don't mock the database.** Bind `InMemoryDbModule` (`package:common/testing/in_memory_db_module.dart`) — a real drift DB in memory, so queries, watches and upserts run for real.
- **Don't mock `NostrClient` or `AsyncFetcher`.** Construct a real `NostrClient(channelFactory: mockChannelFactory)` and mock only `ChannelFactory` / the WebSocket channel, feeding relay frames (`["EVENT", subId, {...}]`, `["EOSE", subId]`). See `packages/notes/test/auth/domain/create_note_usecase_test.dart` and `packages/nostr/test/nostr_client/async_fetcher_test.dart`.
- Assert on what the UI would see: the `GetX` stream / rendered widgets after the relay frame arrives, and outbox rows after a write — not on which repository methods were called.
