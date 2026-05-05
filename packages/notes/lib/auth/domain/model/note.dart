import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';

final class Note extends Equatable {
  static const initAtTag = 'init_at';
  static const labelsTag = 'labels';
  final String eventId;
  final String dTag;
  final String content;
  final String _summary;
  final DateTime createdAt;
  final DateTime initAt;
  final Object? error;
  final List<BaseLabel> labels;

  const Note({
    required this.eventId,
    required this.dTag,
    required this.content,
    required String summary,
    required this.createdAt,
    required this.initAt,
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
    initAt,
    error,
    labels,
  ];

  Note copyWith({
    String? content,
    String? summary,
    Object? error,
    DateTime? createdAt,
    DateTime? initAt,
    List<BaseLabel>? labels,
  }) {
    return Note(
      eventId: eventId,
      dTag: dTag,
      content: content ?? this.content,
      summary: summary ?? _summary,
      createdAt: createdAt ?? this.createdAt,
      initAt: initAt ?? this.initAt,
      labels: labels ?? this.labels,
      error: error ?? this.error,
    );
  }

  String get summary => _summary.trim();
}
