import 'package:equatable/equatable.dart';
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';

final class Note extends Equatable {
  /// Tag key for [updatedAt]. NOTE: the tag/field name `updated_at` is a
  /// misnomer — semantically this is `init_at`. See [updatedAt].
  static const updatedAtTag = 'updated_at';
  static const labelsTag = 'labels';
  static String get clientTagValue => AppConfig.clientTagValue;
  final String eventId;
  final String dTag;
  final String content;
  final String _summary;

  /// Nostr `created_at`: the event's publication timestamp. Per the Nostr
  /// protocol it is refreshed to "now" on every (re)publish/update, and the
  /// event store resolves replaceable-event (kind 30000–40000) conflicts by
  /// comparing it. It is NOT the note's original creation date.
  final DateTime createdAt;

  /// Misleadingly named — this is effectively `init_at`, not "last updated".
  /// It tracks the last time the note's *content* changed and is refreshed on
  /// content edits, but deliberately preserved when only labels change (see
  /// `CreateNoteUsecase.assignLabels`) and when a note is imported. Stored in
  /// the [updatedAtTag] tag.
  final DateTime updatedAt;
  final Object? error;
  final List<BaseLabel> labels;

  const Note({
    required this.eventId,
    required this.dTag,
    required this.content,
    required String summary,
    required this.createdAt,
    required this.updatedAt,
    this.labels = const [],
    this.error,
  }) : _summary = summary;

  @override
  List<Object?> get props => [
    eventId,
    dTag,
    content,
    _summary,
    createdAt,
    updatedAt,
    error,
    labels,
  ];

  Note copyWith({
    String? content,
    String? summary,
    Object? error,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<BaseLabel>? labels,
  }) {
    return Note(
      eventId: eventId,
      dTag: dTag,
      content: content ?? this.content,
      summary: summary ?? _summary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      labels: labels ?? this.labels,
      error: error ?? this.error,
    );
  }

  String get summary => _summary.trim();
}
