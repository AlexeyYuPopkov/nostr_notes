import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/core/tools/optional_box.dart';

final class NoteBlocData extends Equatable {
  final OptionalBox<Note> initialNote;
  final bool hasChanges;
  // final String text;
  const NoteBlocData._({required this.initialNote, required this.hasChanges});

  factory NoteBlocData.initial() {
    return const NoteBlocData._(
      initialNote: OptionalBox(null),
      hasChanges: false,
    );
  }

  @override
  List<Object?> get props => [initialNote, hasChanges];

  NoteBlocData copyWith({OptionalBox<Note>? initialNote, bool? hasChanges}) {
    return NoteBlocData._(
      initialNote: initialNote ?? this.initialNote,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }
}
