// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_class_probabilities_dao.dart';

// ignore_for_file: type=lint
mixin _$NoteClassProbabilitiesDaoMixin on DatabaseAccessor<AppDatabase> {
  $NostrEventsTable get nostrEvents => attachedDatabase.nostrEvents;
  $NoteClassProbabilitiesTable get noteClassProbabilities =>
      attachedDatabase.noteClassProbabilities;
  NoteClassProbabilitiesDaoManager get managers =>
      NoteClassProbabilitiesDaoManager(this);
}

class NoteClassProbabilitiesDaoManager {
  final _$NoteClassProbabilitiesDaoMixin _db;
  NoteClassProbabilitiesDaoManager(this._db);
  $$NostrEventsTableTableManager get nostrEvents =>
      $$NostrEventsTableTableManager(_db.attachedDatabase, _db.nostrEvents);
  $$NoteClassProbabilitiesTableTableManager get noteClassProbabilities =>
      $$NoteClassProbabilitiesTableTableManager(
        _db.attachedDatabase,
        _db.noteClassProbabilities,
      );
}
