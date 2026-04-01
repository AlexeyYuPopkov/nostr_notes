import 'package:equatable/equatable.dart';

import 'package:nostr_notes/common/presentation/formatters/date_group.dart';

final class NotesListData extends Equatable {
  final List<NotesListSection> sections;
  const NotesListData._({required this.sections});

  factory NotesListData.initial() {
    return const NotesListData._(sections: []);
  }

  @override
  List<Object?> get props => [sections];

  NotesListData copyWith({List<NotesListSection>? sections}) {
    return NotesListData._(sections: sections ?? this.sections);
  }
}
