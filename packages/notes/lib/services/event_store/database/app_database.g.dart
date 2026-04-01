// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $NostrEventsTable extends NostrEvents
    with TableInfo<$NostrEventsTable, NostrEventData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NostrEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<int> kind = GeneratedColumn<int>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pubkeyMeta = const VerificationMeta('pubkey');
  @override
  late final GeneratedColumn<String> pubkey = GeneratedColumn<String>(
    'pubkey',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<int> receivedAt = GeneratedColumn<int>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sigMeta = const VerificationMeta('sig');
  @override
  late final GeneratedColumn<String> sig = GeneratedColumn<String>(
    'sig',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    pubkey,
    createdAt,
    receivedAt,
    content,
    sig,
    tags,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nostr_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<NostrEventData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('pubkey')) {
      context.handle(
        _pubkeyMeta,
        pubkey.isAcceptableOrUnknown(data['pubkey']!, _pubkeyMeta),
      );
    } else if (isInserting) {
      context.missing(_pubkeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('sig')) {
      context.handle(
        _sigMeta,
        sig.isAcceptableOrUnknown(data['sig']!, _sigMeta),
      );
    } else if (isInserting) {
      context.missing(_sigMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NostrEventData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NostrEventData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kind'],
      )!,
      pubkey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pubkey'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}received_at'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      sig: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sig'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
    );
  }

  @override
  $NostrEventsTable createAlias(String alias) {
    return $NostrEventsTable(attachedDatabase, alias);
  }
}

class NostrEventData extends DataClass implements Insertable<NostrEventData> {
  /// Nostr event id (32-byte hex string)
  final String id;

  /// Kind, e.g. 1 (note), 7 (reaction), etc.
  final int kind;

  /// Pubkey of author
  final String pubkey;

  /// Unix seconds from Nostr event `created_at`
  final int createdAt;

  /// When this event was added to the database (milliseconds)
  final int receivedAt;
  final String content;

  /// Signature
  final String sig;

  /// Serialized tags array
  final String tags;
  const NostrEventData({
    required this.id,
    required this.kind,
    required this.pubkey,
    required this.createdAt,
    required this.receivedAt,
    required this.content,
    required this.sig,
    required this.tags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<int>(kind);
    map['pubkey'] = Variable<String>(pubkey);
    map['created_at'] = Variable<int>(createdAt);
    map['received_at'] = Variable<int>(receivedAt);
    map['content'] = Variable<String>(content);
    map['sig'] = Variable<String>(sig);
    map['tags'] = Variable<String>(tags);
    return map;
  }

  NostrEventsCompanion toCompanion(bool nullToAbsent) {
    return NostrEventsCompanion(
      id: Value(id),
      kind: Value(kind),
      pubkey: Value(pubkey),
      createdAt: Value(createdAt),
      receivedAt: Value(receivedAt),
      content: Value(content),
      sig: Value(sig),
      tags: Value(tags),
    );
  }

  factory NostrEventData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NostrEventData(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<int>(json['kind']),
      pubkey: serializer.fromJson<String>(json['pubkey']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      receivedAt: serializer.fromJson<int>(json['receivedAt']),
      content: serializer.fromJson<String>(json['content']),
      sig: serializer.fromJson<String>(json['sig']),
      tags: serializer.fromJson<String>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<int>(kind),
      'pubkey': serializer.toJson<String>(pubkey),
      'createdAt': serializer.toJson<int>(createdAt),
      'receivedAt': serializer.toJson<int>(receivedAt),
      'content': serializer.toJson<String>(content),
      'sig': serializer.toJson<String>(sig),
      'tags': serializer.toJson<String>(tags),
    };
  }

  NostrEventData copyWith({
    String? id,
    int? kind,
    String? pubkey,
    int? createdAt,
    int? receivedAt,
    String? content,
    String? sig,
    String? tags,
  }) => NostrEventData(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    pubkey: pubkey ?? this.pubkey,
    createdAt: createdAt ?? this.createdAt,
    receivedAt: receivedAt ?? this.receivedAt,
    content: content ?? this.content,
    sig: sig ?? this.sig,
    tags: tags ?? this.tags,
  );
  NostrEventData copyWithCompanion(NostrEventsCompanion data) {
    return NostrEventData(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      pubkey: data.pubkey.present ? data.pubkey.value : this.pubkey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      content: data.content.present ? data.content.value : this.content,
      sig: data.sig.present ? data.sig.value : this.sig,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NostrEventData(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('pubkey: $pubkey, ')
          ..write('createdAt: $createdAt, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('content: $content, ')
          ..write('sig: $sig, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, kind, pubkey, createdAt, receivedAt, content, sig, tags);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NostrEventData &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.pubkey == this.pubkey &&
          other.createdAt == this.createdAt &&
          other.receivedAt == this.receivedAt &&
          other.content == this.content &&
          other.sig == this.sig &&
          other.tags == this.tags);
}

class NostrEventsCompanion extends UpdateCompanion<NostrEventData> {
  final Value<String> id;
  final Value<int> kind;
  final Value<String> pubkey;
  final Value<int> createdAt;
  final Value<int> receivedAt;
  final Value<String> content;
  final Value<String> sig;
  final Value<String> tags;
  final Value<int> rowid;
  const NostrEventsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.pubkey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.content = const Value.absent(),
    this.sig = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NostrEventsCompanion.insert({
    required String id,
    required int kind,
    required String pubkey,
    required int createdAt,
    required int receivedAt,
    required String content,
    required String sig,
    required String tags,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       pubkey = Value(pubkey),
       createdAt = Value(createdAt),
       receivedAt = Value(receivedAt),
       content = Value(content),
       sig = Value(sig),
       tags = Value(tags);
  static Insertable<NostrEventData> custom({
    Expression<String>? id,
    Expression<int>? kind,
    Expression<String>? pubkey,
    Expression<int>? createdAt,
    Expression<int>? receivedAt,
    Expression<String>? content,
    Expression<String>? sig,
    Expression<String>? tags,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (pubkey != null) 'pubkey': pubkey,
      if (createdAt != null) 'created_at': createdAt,
      if (receivedAt != null) 'received_at': receivedAt,
      if (content != null) 'content': content,
      if (sig != null) 'sig': sig,
      if (tags != null) 'tags': tags,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NostrEventsCompanion copyWith({
    Value<String>? id,
    Value<int>? kind,
    Value<String>? pubkey,
    Value<int>? createdAt,
    Value<int>? receivedAt,
    Value<String>? content,
    Value<String>? sig,
    Value<String>? tags,
    Value<int>? rowid,
  }) {
    return NostrEventsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      pubkey: pubkey ?? this.pubkey,
      createdAt: createdAt ?? this.createdAt,
      receivedAt: receivedAt ?? this.receivedAt,
      content: content ?? this.content,
      sig: sig ?? this.sig,
      tags: tags ?? this.tags,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>(kind.value);
    }
    if (pubkey.present) {
      map['pubkey'] = Variable<String>(pubkey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<int>(receivedAt.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (sig.present) {
      map['sig'] = Variable<String>(sig.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NostrEventsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('pubkey: $pubkey, ')
          ..write('createdAt: $createdAt, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('content: $content, ')
          ..write('sig: $sig, ')
          ..write('tags: $tags, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NostrTagsTable extends NostrTags
    with TableInfo<$NostrTagsTable, NostrTagData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NostrTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES nostr_events (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extraJsonMeta = const VerificationMeta(
    'extraJson',
  );
  @override
  late final GeneratedColumn<String> extraJson = GeneratedColumn<String>(
    'extra_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, eventId, tag, value, extraJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nostr_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<NostrTagData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('extra_json')) {
      context.handle(
        _extraJsonMeta,
        extraJson.isAcceptableOrUnknown(data['extra_json']!, _extraJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NostrTagData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NostrTagData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      extraJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra_json'],
      ),
    );
  }

  @override
  $NostrTagsTable createAlias(String alias) {
    return $NostrTagsTable(attachedDatabase, alias);
  }
}

class NostrTagData extends DataClass implements Insertable<NostrTagData> {
  final int id;
  final String eventId;
  final String tag;
  final String value;
  final String? extraJson;
  const NostrTagData({
    required this.id,
    required this.eventId,
    required this.tag,
    required this.value,
    this.extraJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_id'] = Variable<String>(eventId);
    map['tag'] = Variable<String>(tag);
    map['value'] = Variable<String>(value);
    if (!nullToAbsent || extraJson != null) {
      map['extra_json'] = Variable<String>(extraJson);
    }
    return map;
  }

  NostrTagsCompanion toCompanion(bool nullToAbsent) {
    return NostrTagsCompanion(
      id: Value(id),
      eventId: Value(eventId),
      tag: Value(tag),
      value: Value(value),
      extraJson: extraJson == null && nullToAbsent
          ? const Value.absent()
          : Value(extraJson),
    );
  }

  factory NostrTagData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NostrTagData(
      id: serializer.fromJson<int>(json['id']),
      eventId: serializer.fromJson<String>(json['eventId']),
      tag: serializer.fromJson<String>(json['tag']),
      value: serializer.fromJson<String>(json['value']),
      extraJson: serializer.fromJson<String?>(json['extraJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventId': serializer.toJson<String>(eventId),
      'tag': serializer.toJson<String>(tag),
      'value': serializer.toJson<String>(value),
      'extraJson': serializer.toJson<String?>(extraJson),
    };
  }

  NostrTagData copyWith({
    int? id,
    String? eventId,
    String? tag,
    String? value,
    Value<String?> extraJson = const Value.absent(),
  }) => NostrTagData(
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    tag: tag ?? this.tag,
    value: value ?? this.value,
    extraJson: extraJson.present ? extraJson.value : this.extraJson,
  );
  NostrTagData copyWithCompanion(NostrTagsCompanion data) {
    return NostrTagData(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      tag: data.tag.present ? data.tag.value : this.tag,
      value: data.value.present ? data.value.value : this.value,
      extraJson: data.extraJson.present ? data.extraJson.value : this.extraJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NostrTagData(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('tag: $tag, ')
          ..write('value: $value, ')
          ..write('extraJson: $extraJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, eventId, tag, value, extraJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NostrTagData &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.tag == this.tag &&
          other.value == this.value &&
          other.extraJson == this.extraJson);
}

class NostrTagsCompanion extends UpdateCompanion<NostrTagData> {
  final Value<int> id;
  final Value<String> eventId;
  final Value<String> tag;
  final Value<String> value;
  final Value<String?> extraJson;
  const NostrTagsCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.tag = const Value.absent(),
    this.value = const Value.absent(),
    this.extraJson = const Value.absent(),
  });
  NostrTagsCompanion.insert({
    this.id = const Value.absent(),
    required String eventId,
    required String tag,
    required String value,
    this.extraJson = const Value.absent(),
  }) : eventId = Value(eventId),
       tag = Value(tag),
       value = Value(value);
  static Insertable<NostrTagData> custom({
    Expression<int>? id,
    Expression<String>? eventId,
    Expression<String>? tag,
    Expression<String>? value,
    Expression<String>? extraJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (tag != null) 'tag': tag,
      if (value != null) 'value': value,
      if (extraJson != null) 'extra_json': extraJson,
    });
  }

  NostrTagsCompanion copyWith({
    Value<int>? id,
    Value<String>? eventId,
    Value<String>? tag,
    Value<String>? value,
    Value<String?>? extraJson,
  }) {
    return NostrTagsCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      tag: tag ?? this.tag,
      value: value ?? this.value,
      extraJson: extraJson ?? this.extraJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (extraJson.present) {
      map['extra_json'] = Variable<String>(extraJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NostrTagsCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('tag: $tag, ')
          ..write('value: $value, ')
          ..write('extraJson: $extraJson')
          ..write(')'))
        .toString();
  }
}

class $NostrEventRelaysTable extends NostrEventRelays
    with TableInfo<$NostrEventRelaysTable, NostrEventRelayData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NostrEventRelaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES nostr_events (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _relayUrlMeta = const VerificationMeta(
    'relayUrl',
  );
  @override
  late final GeneratedColumn<String> relayUrl = GeneratedColumn<String>(
    'relay_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstSeenAtMeta = const VerificationMeta(
    'firstSeenAt',
  );
  @override
  late final GeneratedColumn<int> firstSeenAt = GeneratedColumn<int>(
    'first_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, eventId, relayUrl, firstSeenAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nostr_event_relays';
  @override
  VerificationContext validateIntegrity(
    Insertable<NostrEventRelayData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('relay_url')) {
      context.handle(
        _relayUrlMeta,
        relayUrl.isAcceptableOrUnknown(data['relay_url']!, _relayUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_relayUrlMeta);
    }
    if (data.containsKey('first_seen_at')) {
      context.handle(
        _firstSeenAtMeta,
        firstSeenAt.isAcceptableOrUnknown(
          data['first_seen_at']!,
          _firstSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstSeenAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {eventId, relayUrl},
  ];
  @override
  NostrEventRelayData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NostrEventRelayData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      relayUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relay_url'],
      )!,
      firstSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_seen_at'],
      )!,
    );
  }

  @override
  $NostrEventRelaysTable createAlias(String alias) {
    return $NostrEventRelaysTable(attachedDatabase, alias);
  }
}

class NostrEventRelayData extends DataClass
    implements Insertable<NostrEventRelayData> {
  final int id;
  final String eventId;
  final String relayUrl;
  final int firstSeenAt;
  const NostrEventRelayData({
    required this.id,
    required this.eventId,
    required this.relayUrl,
    required this.firstSeenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_id'] = Variable<String>(eventId);
    map['relay_url'] = Variable<String>(relayUrl);
    map['first_seen_at'] = Variable<int>(firstSeenAt);
    return map;
  }

  NostrEventRelaysCompanion toCompanion(bool nullToAbsent) {
    return NostrEventRelaysCompanion(
      id: Value(id),
      eventId: Value(eventId),
      relayUrl: Value(relayUrl),
      firstSeenAt: Value(firstSeenAt),
    );
  }

  factory NostrEventRelayData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NostrEventRelayData(
      id: serializer.fromJson<int>(json['id']),
      eventId: serializer.fromJson<String>(json['eventId']),
      relayUrl: serializer.fromJson<String>(json['relayUrl']),
      firstSeenAt: serializer.fromJson<int>(json['firstSeenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventId': serializer.toJson<String>(eventId),
      'relayUrl': serializer.toJson<String>(relayUrl),
      'firstSeenAt': serializer.toJson<int>(firstSeenAt),
    };
  }

  NostrEventRelayData copyWith({
    int? id,
    String? eventId,
    String? relayUrl,
    int? firstSeenAt,
  }) => NostrEventRelayData(
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    relayUrl: relayUrl ?? this.relayUrl,
    firstSeenAt: firstSeenAt ?? this.firstSeenAt,
  );
  NostrEventRelayData copyWithCompanion(NostrEventRelaysCompanion data) {
    return NostrEventRelayData(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      relayUrl: data.relayUrl.present ? data.relayUrl.value : this.relayUrl,
      firstSeenAt: data.firstSeenAt.present
          ? data.firstSeenAt.value
          : this.firstSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NostrEventRelayData(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('relayUrl: $relayUrl, ')
          ..write('firstSeenAt: $firstSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, eventId, relayUrl, firstSeenAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NostrEventRelayData &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.relayUrl == this.relayUrl &&
          other.firstSeenAt == this.firstSeenAt);
}

class NostrEventRelaysCompanion extends UpdateCompanion<NostrEventRelayData> {
  final Value<int> id;
  final Value<String> eventId;
  final Value<String> relayUrl;
  final Value<int> firstSeenAt;
  const NostrEventRelaysCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.relayUrl = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
  });
  NostrEventRelaysCompanion.insert({
    this.id = const Value.absent(),
    required String eventId,
    required String relayUrl,
    required int firstSeenAt,
  }) : eventId = Value(eventId),
       relayUrl = Value(relayUrl),
       firstSeenAt = Value(firstSeenAt);
  static Insertable<NostrEventRelayData> custom({
    Expression<int>? id,
    Expression<String>? eventId,
    Expression<String>? relayUrl,
    Expression<int>? firstSeenAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (relayUrl != null) 'relay_url': relayUrl,
      if (firstSeenAt != null) 'first_seen_at': firstSeenAt,
    });
  }

  NostrEventRelaysCompanion copyWith({
    Value<int>? id,
    Value<String>? eventId,
    Value<String>? relayUrl,
    Value<int>? firstSeenAt,
  }) {
    return NostrEventRelaysCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      relayUrl: relayUrl ?? this.relayUrl,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (relayUrl.present) {
      map['relay_url'] = Variable<String>(relayUrl.value);
    }
    if (firstSeenAt.present) {
      map['first_seen_at'] = Variable<int>(firstSeenAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NostrEventRelaysCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('relayUrl: $relayUrl, ')
          ..write('firstSeenAt: $firstSeenAt')
          ..write(')'))
        .toString();
  }
}

class $OutboxEventsTable extends OutboxEvents
    with TableInfo<$OutboxEventsTable, OutboxEventData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<OutboxStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(OutboxStatus.pending.index),
      ).withConverter<OutboxStatus>($OutboxEventsTable.$converterstatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<int> lastAttemptAt = GeneratedColumn<int>(
    'last_attempt_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _failureReasonMeta = const VerificationMeta(
    'failureReason',
  );
  @override
  late final GeneratedColumn<String> failureReason = GeneratedColumn<String>(
    'failure_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confirmedRelaysMeta = const VerificationMeta(
    'confirmedRelays',
  );
  @override
  late final GeneratedColumn<String> confirmedRelays = GeneratedColumn<String>(
    'confirmed_relays',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    status,
    createdAt,
    lastAttemptAt,
    attemptCount,
    failureReason,
    confirmedRelays,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEventData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('failure_reason')) {
      context.handle(
        _failureReasonMeta,
        failureReason.isAcceptableOrUnknown(
          data['failure_reason']!,
          _failureReasonMeta,
        ),
      );
    }
    if (data.containsKey('confirmed_relays')) {
      context.handle(
        _confirmedRelaysMeta,
        confirmedRelays.isAcceptableOrUnknown(
          data['confirmed_relays']!,
          _confirmedRelaysMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  OutboxEventData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEventData(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      status: $OutboxEventsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_attempt_at'],
      ),
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      failureReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_reason'],
      ),
      confirmedRelays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confirmed_relays'],
      ),
    );
  }

  @override
  $OutboxEventsTable createAlias(String alias) {
    return $OutboxEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OutboxStatus, int, int> $converterstatus =
      const EnumIndexConverter<OutboxStatus>(OutboxStatus.values);
}

class OutboxEventData extends DataClass implements Insertable<OutboxEventData> {
  /// The Nostr event ID (FK to nostr_events.id)
  final String eventId;

  /// Current status of the publish attempt
  final OutboxStatus status;

  /// When the event was queued for publishing (ms since epoch)
  final int createdAt;

  /// When the last publish attempt was made (ms since epoch)
  final int? lastAttemptAt;

  /// Number of publish attempts made
  final int attemptCount;

  /// Error message if status is failed
  final String? failureReason;

  /// JSON array of relay URLs that confirmed receipt
  final String? confirmedRelays;
  const OutboxEventData({
    required this.eventId,
    required this.status,
    required this.createdAt,
    this.lastAttemptAt,
    required this.attemptCount,
    this.failureReason,
    this.confirmedRelays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    {
      map['status'] = Variable<int>(
        $OutboxEventsTable.$converterstatus.toSql(status),
      );
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<int>(lastAttemptAt);
    }
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || failureReason != null) {
      map['failure_reason'] = Variable<String>(failureReason);
    }
    if (!nullToAbsent || confirmedRelays != null) {
      map['confirmed_relays'] = Variable<String>(confirmedRelays);
    }
    return map;
  }

  OutboxEventsCompanion toCompanion(bool nullToAbsent) {
    return OutboxEventsCompanion(
      eventId: Value(eventId),
      status: Value(status),
      createdAt: Value(createdAt),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      attemptCount: Value(attemptCount),
      failureReason: failureReason == null && nullToAbsent
          ? const Value.absent()
          : Value(failureReason),
      confirmedRelays: confirmedRelays == null && nullToAbsent
          ? const Value.absent()
          : Value(confirmedRelays),
    );
  }

  factory OutboxEventData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEventData(
      eventId: serializer.fromJson<String>(json['eventId']),
      status: $OutboxEventsTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      lastAttemptAt: serializer.fromJson<int?>(json['lastAttemptAt']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      failureReason: serializer.fromJson<String?>(json['failureReason']),
      confirmedRelays: serializer.fromJson<String?>(json['confirmedRelays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'status': serializer.toJson<int>(
        $OutboxEventsTable.$converterstatus.toJson(status),
      ),
      'createdAt': serializer.toJson<int>(createdAt),
      'lastAttemptAt': serializer.toJson<int?>(lastAttemptAt),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'failureReason': serializer.toJson<String?>(failureReason),
      'confirmedRelays': serializer.toJson<String?>(confirmedRelays),
    };
  }

  OutboxEventData copyWith({
    String? eventId,
    OutboxStatus? status,
    int? createdAt,
    Value<int?> lastAttemptAt = const Value.absent(),
    int? attemptCount,
    Value<String?> failureReason = const Value.absent(),
    Value<String?> confirmedRelays = const Value.absent(),
  }) => OutboxEventData(
    eventId: eventId ?? this.eventId,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    attemptCount: attemptCount ?? this.attemptCount,
    failureReason: failureReason.present
        ? failureReason.value
        : this.failureReason,
    confirmedRelays: confirmedRelays.present
        ? confirmedRelays.value
        : this.confirmedRelays,
  );
  OutboxEventData copyWithCompanion(OutboxEventsCompanion data) {
    return OutboxEventData(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      failureReason: data.failureReason.present
          ? data.failureReason.value
          : this.failureReason,
      confirmedRelays: data.confirmedRelays.present
          ? data.confirmedRelays.value
          : this.confirmedRelays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEventData(')
          ..write('eventId: $eventId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('failureReason: $failureReason, ')
          ..write('confirmedRelays: $confirmedRelays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    eventId,
    status,
    createdAt,
    lastAttemptAt,
    attemptCount,
    failureReason,
    confirmedRelays,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEventData &&
          other.eventId == this.eventId &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.attemptCount == this.attemptCount &&
          other.failureReason == this.failureReason &&
          other.confirmedRelays == this.confirmedRelays);
}

class OutboxEventsCompanion extends UpdateCompanion<OutboxEventData> {
  final Value<String> eventId;
  final Value<OutboxStatus> status;
  final Value<int> createdAt;
  final Value<int?> lastAttemptAt;
  final Value<int> attemptCount;
  final Value<String?> failureReason;
  final Value<String?> confirmedRelays;
  final Value<int> rowid;
  const OutboxEventsCompanion({
    this.eventId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.confirmedRelays = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxEventsCompanion.insert({
    required String eventId,
    this.status = const Value.absent(),
    required int createdAt,
    this.lastAttemptAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.confirmedRelays = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       createdAt = Value(createdAt);
  static Insertable<OutboxEventData> custom({
    Expression<String>? eventId,
    Expression<int>? status,
    Expression<int>? createdAt,
    Expression<int>? lastAttemptAt,
    Expression<int>? attemptCount,
    Expression<String>? failureReason,
    Expression<String>? confirmedRelays,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (failureReason != null) 'failure_reason': failureReason,
      if (confirmedRelays != null) 'confirmed_relays': confirmedRelays,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxEventsCompanion copyWith({
    Value<String>? eventId,
    Value<OutboxStatus>? status,
    Value<int>? createdAt,
    Value<int?>? lastAttemptAt,
    Value<int>? attemptCount,
    Value<String?>? failureReason,
    Value<String?>? confirmedRelays,
    Value<int>? rowid,
  }) {
    return OutboxEventsCompanion(
      eventId: eventId ?? this.eventId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      attemptCount: attemptCount ?? this.attemptCount,
      failureReason: failureReason ?? this.failureReason,
      confirmedRelays: confirmedRelays ?? this.confirmedRelays,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $OutboxEventsTable.$converterstatus.toSql(status.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<int>(lastAttemptAt.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (failureReason.present) {
      map['failure_reason'] = Variable<String>(failureReason.value);
    }
    if (confirmedRelays.present) {
      map['confirmed_relays'] = Variable<String>(confirmedRelays.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEventsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('failureReason: $failureReason, ')
          ..write('confirmedRelays: $confirmedRelays, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NostrEventsTable nostrEvents = $NostrEventsTable(this);
  late final $NostrTagsTable nostrTags = $NostrTagsTable(this);
  late final $NostrEventRelaysTable nostrEventRelays = $NostrEventRelaysTable(
    this,
  );
  late final $OutboxEventsTable outboxEvents = $OutboxEventsTable(this);
  late final Index idxNostrEventsKindCreatedAt = Index(
    'idx_nostr_events_kind_created_at',
    'CREATE INDEX idx_nostr_events_kind_created_at ON nostr_events (kind, created_at DESC)',
  );
  late final Index idxNostrEventsPubkeyCreatedAt = Index(
    'idx_nostr_events_pubkey_created_at',
    'CREATE INDEX idx_nostr_events_pubkey_created_at ON nostr_events (pubkey, pubkey DESC)',
  );
  late final Index idxNostrTagsTagValue = Index(
    'idx_nostr_tags_tag_value',
    'CREATE INDEX idx_nostr_tags_tag_value ON nostr_tags (tag, value)',
  );
  late final Index idxNostrTagsEventId = Index(
    'idx_nostr_tags_event_id',
    'CREATE INDEX idx_nostr_tags_event_id ON nostr_tags (event_id)',
  );
  late final Index idxOutboxStatusCreated = Index(
    'idx_outbox_status_created',
    'CREATE INDEX idx_outbox_status_created ON outbox_events (status, created_at)',
  );
  late final NostrEventDao nostrEventDao = NostrEventDao(this as AppDatabase);
  late final OutboxDao outboxDao = OutboxDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    nostrEvents,
    nostrTags,
    nostrEventRelays,
    outboxEvents,
    idxNostrEventsKindCreatedAt,
    idxNostrEventsPubkeyCreatedAt,
    idxNostrTagsTagValue,
    idxNostrTagsEventId,
    idxOutboxStatusCreated,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'nostr_events',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('nostr_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'nostr_events',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('nostr_event_relays', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$NostrEventsTableCreateCompanionBuilder =
    NostrEventsCompanion Function({
      required String id,
      required int kind,
      required String pubkey,
      required int createdAt,
      required int receivedAt,
      required String content,
      required String sig,
      required String tags,
      Value<int> rowid,
    });
typedef $$NostrEventsTableUpdateCompanionBuilder =
    NostrEventsCompanion Function({
      Value<String> id,
      Value<int> kind,
      Value<String> pubkey,
      Value<int> createdAt,
      Value<int> receivedAt,
      Value<String> content,
      Value<String> sig,
      Value<String> tags,
      Value<int> rowid,
    });

final class $$NostrEventsTableReferences
    extends BaseReferences<_$AppDatabase, $NostrEventsTable, NostrEventData> {
  $$NostrEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NostrTagsTable, List<NostrTagData>>
  _nostrTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.nostrTags,
    aliasName: $_aliasNameGenerator(db.nostrEvents.id, db.nostrTags.eventId),
  );

  $$NostrTagsTableProcessedTableManager get nostrTagsRefs {
    final manager = $$NostrTagsTableTableManager(
      $_db,
      $_db.nostrTags,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_nostrTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NostrEventRelaysTable, List<NostrEventRelayData>>
  _nostrEventRelaysRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.nostrEventRelays,
    aliasName: $_aliasNameGenerator(
      db.nostrEvents.id,
      db.nostrEventRelays.eventId,
    ),
  );

  $$NostrEventRelaysTableProcessedTableManager get nostrEventRelaysRefs {
    final manager = $$NostrEventRelaysTableTableManager(
      $_db,
      $_db.nostrEventRelays,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _nostrEventRelaysRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NostrEventsTableFilterComposer
    extends Composer<_$AppDatabase, $NostrEventsTable> {
  $$NostrEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pubkey => $composableBuilder(
    column: $table.pubkey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sig => $composableBuilder(
    column: $table.sig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> nostrTagsRefs(
    Expression<bool> Function($$NostrTagsTableFilterComposer f) f,
  ) {
    final $$NostrTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.nostrTags,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NostrTagsTableFilterComposer(
            $db: $db,
            $table: $db.nostrTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> nostrEventRelaysRefs(
    Expression<bool> Function($$NostrEventRelaysTableFilterComposer f) f,
  ) {
    final $$NostrEventRelaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.nostrEventRelays,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NostrEventRelaysTableFilterComposer(
            $db: $db,
            $table: $db.nostrEventRelays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NostrEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $NostrEventsTable> {
  $$NostrEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pubkey => $composableBuilder(
    column: $table.pubkey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sig => $composableBuilder(
    column: $table.sig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NostrEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NostrEventsTable> {
  $$NostrEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get pubkey =>
      $composableBuilder(column: $table.pubkey, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get sig =>
      $composableBuilder(column: $table.sig, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  Expression<T> nostrTagsRefs<T extends Object>(
    Expression<T> Function($$NostrTagsTableAnnotationComposer a) f,
  ) {
    final $$NostrTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.nostrTags,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NostrTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.nostrTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> nostrEventRelaysRefs<T extends Object>(
    Expression<T> Function($$NostrEventRelaysTableAnnotationComposer a) f,
  ) {
    final $$NostrEventRelaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.nostrEventRelays,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NostrEventRelaysTableAnnotationComposer(
            $db: $db,
            $table: $db.nostrEventRelays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NostrEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NostrEventsTable,
          NostrEventData,
          $$NostrEventsTableFilterComposer,
          $$NostrEventsTableOrderingComposer,
          $$NostrEventsTableAnnotationComposer,
          $$NostrEventsTableCreateCompanionBuilder,
          $$NostrEventsTableUpdateCompanionBuilder,
          (NostrEventData, $$NostrEventsTableReferences),
          NostrEventData,
          PrefetchHooks Function({
            bool nostrTagsRefs,
            bool nostrEventRelaysRefs,
          })
        > {
  $$NostrEventsTableTableManager(_$AppDatabase db, $NostrEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NostrEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NostrEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NostrEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> kind = const Value.absent(),
                Value<String> pubkey = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> receivedAt = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> sig = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NostrEventsCompanion(
                id: id,
                kind: kind,
                pubkey: pubkey,
                createdAt: createdAt,
                receivedAt: receivedAt,
                content: content,
                sig: sig,
                tags: tags,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int kind,
                required String pubkey,
                required int createdAt,
                required int receivedAt,
                required String content,
                required String sig,
                required String tags,
                Value<int> rowid = const Value.absent(),
              }) => NostrEventsCompanion.insert(
                id: id,
                kind: kind,
                pubkey: pubkey,
                createdAt: createdAt,
                receivedAt: receivedAt,
                content: content,
                sig: sig,
                tags: tags,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NostrEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({nostrTagsRefs = false, nostrEventRelaysRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (nostrTagsRefs) db.nostrTags,
                    if (nostrEventRelaysRefs) db.nostrEventRelays,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (nostrTagsRefs)
                        await $_getPrefetchedData<
                          NostrEventData,
                          $NostrEventsTable,
                          NostrTagData
                        >(
                          currentTable: table,
                          referencedTable: $$NostrEventsTableReferences
                              ._nostrTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NostrEventsTableReferences(
                                db,
                                table,
                                p0,
                              ).nostrTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eventId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (nostrEventRelaysRefs)
                        await $_getPrefetchedData<
                          NostrEventData,
                          $NostrEventsTable,
                          NostrEventRelayData
                        >(
                          currentTable: table,
                          referencedTable: $$NostrEventsTableReferences
                              ._nostrEventRelaysRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NostrEventsTableReferences(
                                db,
                                table,
                                p0,
                              ).nostrEventRelaysRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eventId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$NostrEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NostrEventsTable,
      NostrEventData,
      $$NostrEventsTableFilterComposer,
      $$NostrEventsTableOrderingComposer,
      $$NostrEventsTableAnnotationComposer,
      $$NostrEventsTableCreateCompanionBuilder,
      $$NostrEventsTableUpdateCompanionBuilder,
      (NostrEventData, $$NostrEventsTableReferences),
      NostrEventData,
      PrefetchHooks Function({bool nostrTagsRefs, bool nostrEventRelaysRefs})
    >;
typedef $$NostrTagsTableCreateCompanionBuilder =
    NostrTagsCompanion Function({
      Value<int> id,
      required String eventId,
      required String tag,
      required String value,
      Value<String?> extraJson,
    });
typedef $$NostrTagsTableUpdateCompanionBuilder =
    NostrTagsCompanion Function({
      Value<int> id,
      Value<String> eventId,
      Value<String> tag,
      Value<String> value,
      Value<String?> extraJson,
    });

final class $$NostrTagsTableReferences
    extends BaseReferences<_$AppDatabase, $NostrTagsTable, NostrTagData> {
  $$NostrTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NostrEventsTable _eventIdTable(_$AppDatabase db) =>
      db.nostrEvents.createAlias(
        $_aliasNameGenerator(db.nostrTags.eventId, db.nostrEvents.id),
      );

  $$NostrEventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<String>('event_id')!;

    final manager = $$NostrEventsTableTableManager(
      $_db,
      $_db.nostrEvents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NostrTagsTableFilterComposer
    extends Composer<_$AppDatabase, $NostrTagsTable> {
  $$NostrTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extraJson => $composableBuilder(
    column: $table.extraJson,
    builder: (column) => ColumnFilters(column),
  );

  $$NostrEventsTableFilterComposer get eventId {
    final $$NostrEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.nostrEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NostrEventsTableFilterComposer(
            $db: $db,
            $table: $db.nostrEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NostrTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $NostrTagsTable> {
  $$NostrTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extraJson => $composableBuilder(
    column: $table.extraJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$NostrEventsTableOrderingComposer get eventId {
    final $$NostrEventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.nostrEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NostrEventsTableOrderingComposer(
            $db: $db,
            $table: $db.nostrEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NostrTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NostrTagsTable> {
  $$NostrTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get extraJson =>
      $composableBuilder(column: $table.extraJson, builder: (column) => column);

  $$NostrEventsTableAnnotationComposer get eventId {
    final $$NostrEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.nostrEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NostrEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.nostrEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NostrTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NostrTagsTable,
          NostrTagData,
          $$NostrTagsTableFilterComposer,
          $$NostrTagsTableOrderingComposer,
          $$NostrTagsTableAnnotationComposer,
          $$NostrTagsTableCreateCompanionBuilder,
          $$NostrTagsTableUpdateCompanionBuilder,
          (NostrTagData, $$NostrTagsTableReferences),
          NostrTagData,
          PrefetchHooks Function({bool eventId})
        > {
  $$NostrTagsTableTableManager(_$AppDatabase db, $NostrTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NostrTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NostrTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NostrTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<String> tag = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String?> extraJson = const Value.absent(),
              }) => NostrTagsCompanion(
                id: id,
                eventId: eventId,
                tag: tag,
                value: value,
                extraJson: extraJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String eventId,
                required String tag,
                required String value,
                Value<String?> extraJson = const Value.absent(),
              }) => NostrTagsCompanion.insert(
                id: id,
                eventId: eventId,
                tag: tag,
                value: value,
                extraJson: extraJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NostrTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eventId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (eventId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.eventId,
                                referencedTable: $$NostrTagsTableReferences
                                    ._eventIdTable(db),
                                referencedColumn: $$NostrTagsTableReferences
                                    ._eventIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NostrTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NostrTagsTable,
      NostrTagData,
      $$NostrTagsTableFilterComposer,
      $$NostrTagsTableOrderingComposer,
      $$NostrTagsTableAnnotationComposer,
      $$NostrTagsTableCreateCompanionBuilder,
      $$NostrTagsTableUpdateCompanionBuilder,
      (NostrTagData, $$NostrTagsTableReferences),
      NostrTagData,
      PrefetchHooks Function({bool eventId})
    >;
typedef $$NostrEventRelaysTableCreateCompanionBuilder =
    NostrEventRelaysCompanion Function({
      Value<int> id,
      required String eventId,
      required String relayUrl,
      required int firstSeenAt,
    });
typedef $$NostrEventRelaysTableUpdateCompanionBuilder =
    NostrEventRelaysCompanion Function({
      Value<int> id,
      Value<String> eventId,
      Value<String> relayUrl,
      Value<int> firstSeenAt,
    });

final class $$NostrEventRelaysTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NostrEventRelaysTable,
          NostrEventRelayData
        > {
  $$NostrEventRelaysTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NostrEventsTable _eventIdTable(_$AppDatabase db) =>
      db.nostrEvents.createAlias(
        $_aliasNameGenerator(db.nostrEventRelays.eventId, db.nostrEvents.id),
      );

  $$NostrEventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<String>('event_id')!;

    final manager = $$NostrEventsTableTableManager(
      $_db,
      $_db.nostrEvents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NostrEventRelaysTableFilterComposer
    extends Composer<_$AppDatabase, $NostrEventRelaysTable> {
  $$NostrEventRelaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relayUrl => $composableBuilder(
    column: $table.relayUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  $$NostrEventsTableFilterComposer get eventId {
    final $$NostrEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.nostrEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NostrEventsTableFilterComposer(
            $db: $db,
            $table: $db.nostrEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NostrEventRelaysTableOrderingComposer
    extends Composer<_$AppDatabase, $NostrEventRelaysTable> {
  $$NostrEventRelaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relayUrl => $composableBuilder(
    column: $table.relayUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NostrEventsTableOrderingComposer get eventId {
    final $$NostrEventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.nostrEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NostrEventsTableOrderingComposer(
            $db: $db,
            $table: $db.nostrEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NostrEventRelaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $NostrEventRelaysTable> {
  $$NostrEventRelaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relayUrl =>
      $composableBuilder(column: $table.relayUrl, builder: (column) => column);

  GeneratedColumn<int> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => column,
  );

  $$NostrEventsTableAnnotationComposer get eventId {
    final $$NostrEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.nostrEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NostrEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.nostrEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NostrEventRelaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NostrEventRelaysTable,
          NostrEventRelayData,
          $$NostrEventRelaysTableFilterComposer,
          $$NostrEventRelaysTableOrderingComposer,
          $$NostrEventRelaysTableAnnotationComposer,
          $$NostrEventRelaysTableCreateCompanionBuilder,
          $$NostrEventRelaysTableUpdateCompanionBuilder,
          (NostrEventRelayData, $$NostrEventRelaysTableReferences),
          NostrEventRelayData,
          PrefetchHooks Function({bool eventId})
        > {
  $$NostrEventRelaysTableTableManager(
    _$AppDatabase db,
    $NostrEventRelaysTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NostrEventRelaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NostrEventRelaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NostrEventRelaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<String> relayUrl = const Value.absent(),
                Value<int> firstSeenAt = const Value.absent(),
              }) => NostrEventRelaysCompanion(
                id: id,
                eventId: eventId,
                relayUrl: relayUrl,
                firstSeenAt: firstSeenAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String eventId,
                required String relayUrl,
                required int firstSeenAt,
              }) => NostrEventRelaysCompanion.insert(
                id: id,
                eventId: eventId,
                relayUrl: relayUrl,
                firstSeenAt: firstSeenAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NostrEventRelaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eventId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (eventId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.eventId,
                                referencedTable:
                                    $$NostrEventRelaysTableReferences
                                        ._eventIdTable(db),
                                referencedColumn:
                                    $$NostrEventRelaysTableReferences
                                        ._eventIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NostrEventRelaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NostrEventRelaysTable,
      NostrEventRelayData,
      $$NostrEventRelaysTableFilterComposer,
      $$NostrEventRelaysTableOrderingComposer,
      $$NostrEventRelaysTableAnnotationComposer,
      $$NostrEventRelaysTableCreateCompanionBuilder,
      $$NostrEventRelaysTableUpdateCompanionBuilder,
      (NostrEventRelayData, $$NostrEventRelaysTableReferences),
      NostrEventRelayData,
      PrefetchHooks Function({bool eventId})
    >;
typedef $$OutboxEventsTableCreateCompanionBuilder =
    OutboxEventsCompanion Function({
      required String eventId,
      Value<OutboxStatus> status,
      required int createdAt,
      Value<int?> lastAttemptAt,
      Value<int> attemptCount,
      Value<String?> failureReason,
      Value<String?> confirmedRelays,
      Value<int> rowid,
    });
typedef $$OutboxEventsTableUpdateCompanionBuilder =
    OutboxEventsCompanion Function({
      Value<String> eventId,
      Value<OutboxStatus> status,
      Value<int> createdAt,
      Value<int?> lastAttemptAt,
      Value<int> attemptCount,
      Value<String?> failureReason,
      Value<String?> confirmedRelays,
      Value<int> rowid,
    });

class $$OutboxEventsTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxEventsTable> {
  $$OutboxEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OutboxStatus, OutboxStatus, int> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confirmedRelays => $composableBuilder(
    column: $table.confirmedRelays,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxEventsTable> {
  $$OutboxEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confirmedRelays => $composableBuilder(
    column: $table.confirmedRelays,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxEventsTable> {
  $$OutboxEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OutboxStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confirmedRelays => $composableBuilder(
    column: $table.confirmedRelays,
    builder: (column) => column,
  );
}

class $$OutboxEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxEventsTable,
          OutboxEventData,
          $$OutboxEventsTableFilterComposer,
          $$OutboxEventsTableOrderingComposer,
          $$OutboxEventsTableAnnotationComposer,
          $$OutboxEventsTableCreateCompanionBuilder,
          $$OutboxEventsTableUpdateCompanionBuilder,
          (
            OutboxEventData,
            BaseReferences<_$AppDatabase, $OutboxEventsTable, OutboxEventData>,
          ),
          OutboxEventData,
          PrefetchHooks Function()
        > {
  $$OutboxEventsTableTableManager(_$AppDatabase db, $OutboxEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<OutboxStatus> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> lastAttemptAt = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                Value<String?> confirmedRelays = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxEventsCompanion(
                eventId: eventId,
                status: status,
                createdAt: createdAt,
                lastAttemptAt: lastAttemptAt,
                attemptCount: attemptCount,
                failureReason: failureReason,
                confirmedRelays: confirmedRelays,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                Value<OutboxStatus> status = const Value.absent(),
                required int createdAt,
                Value<int?> lastAttemptAt = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                Value<String?> confirmedRelays = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxEventsCompanion.insert(
                eventId: eventId,
                status: status,
                createdAt: createdAt,
                lastAttemptAt: lastAttemptAt,
                attemptCount: attemptCount,
                failureReason: failureReason,
                confirmedRelays: confirmedRelays,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxEventsTable,
      OutboxEventData,
      $$OutboxEventsTableFilterComposer,
      $$OutboxEventsTableOrderingComposer,
      $$OutboxEventsTableAnnotationComposer,
      $$OutboxEventsTableCreateCompanionBuilder,
      $$OutboxEventsTableUpdateCompanionBuilder,
      (
        OutboxEventData,
        BaseReferences<_$AppDatabase, $OutboxEventsTable, OutboxEventData>,
      ),
      OutboxEventData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NostrEventsTableTableManager get nostrEvents =>
      $$NostrEventsTableTableManager(_db, _db.nostrEvents);
  $$NostrTagsTableTableManager get nostrTags =>
      $$NostrTagsTableTableManager(_db, _db.nostrTags);
  $$NostrEventRelaysTableTableManager get nostrEventRelays =>
      $$NostrEventRelaysTableTableManager(_db, _db.nostrEventRelays);
  $$OutboxEventsTableTableManager get outboxEvents =>
      $$OutboxEventsTableTableManager(_db, _db.outboxEvents);
}
