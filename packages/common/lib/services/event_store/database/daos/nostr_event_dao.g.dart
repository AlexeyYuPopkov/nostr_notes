// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nostr_event_dao.dart';

// ignore_for_file: type=lint
mixin _$NostrEventDaoMixin on DatabaseAccessor<AppDatabase> {
  $NostrEventsTable get nostrEvents => attachedDatabase.nostrEvents;
  $NostrTagsTable get nostrTags => attachedDatabase.nostrTags;
  $NostrEventRelaysTable get nostrEventRelays =>
      attachedDatabase.nostrEventRelays;
  NostrEventDaoManager get managers => NostrEventDaoManager(this);
}

class NostrEventDaoManager {
  final _$NostrEventDaoMixin _db;
  NostrEventDaoManager(this._db);
  $$NostrEventsTableTableManager get nostrEvents =>
      $$NostrEventsTableTableManager(_db.attachedDatabase, _db.nostrEvents);
  $$NostrTagsTableTableManager get nostrTags =>
      $$NostrTagsTableTableManager(_db.attachedDatabase, _db.nostrTags);
  $$NostrEventRelaysTableTableManager get nostrEventRelays =>
      $$NostrEventRelaysTableTableManager(
        _db.attachedDatabase,
        _db.nostrEventRelays,
      );
}
