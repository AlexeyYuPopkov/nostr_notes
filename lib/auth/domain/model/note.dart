import 'package:equatable/equatable.dart';

final class Note extends Equatable {
  final String eventId;
  final String dTag;
  final String content;
  final String _summary;
  final DateTime createdAt;
  final Object? error;

  const Note({
    required this.eventId,
    required this.dTag,
    required this.content,
    required String summary,
    required this.createdAt,
    this.error,
  }) : _summary = summary;

  @override
  List<Object?> get props => [
    eventId,
    dTag,
    content,
    _summary,
    createdAt,
    error,
  ];

  Note copyWith({String? content, String? summary, Object? error}) {
    return Note(
      eventId: eventId,
      dTag: dTag,
      content: content ?? this.content,
      summary: summary ?? _summary,
      createdAt: createdAt,
      error: error ?? this.error,
    );
  }

  String get summary => _summary.trim();
}
