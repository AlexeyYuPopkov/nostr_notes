import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';

import '../tabs/notes_list_tab.dart';

final class NotesListData extends Equatable {
  final List<Note> notes;
  final List<NotesListSection> sections;
  final NotesListTab tab;
  final int decryptionErrorCount;

  const NotesListData._({
    required this.notes,
    required this.sections,
    required this.tab,
    required this.decryptionErrorCount,
  });

  factory NotesListData.initial() {
    return const NotesListData._(
      notes: [],
      sections: [],
      tab: NotesListTab.all(),
      decryptionErrorCount: 0,
    );
  }

  bool get hasDecryptionErrors => decryptionErrorCount > 0;

  /// True when every note failed to decrypt — most likely a wrong PIN.
  bool get allNotesFailedDecryption =>
      notes.isNotEmpty && decryptionErrorCount == notes.length;

  @override
  List<Object?> get props => [notes, sections, tab, decryptionErrorCount];

  NotesListData copyWith({
    List<Note>? notes,
    List<NotesListSection>? sections,
    NotesListTab? tab,
    int? decryptionErrorCount,
  }) {
    return NotesListData._(
      notes: notes ?? this.notes,
      sections: sections ?? this.sections,
      tab: tab ?? this.tab,
      decryptionErrorCount: decryptionErrorCount ?? this.decryptionErrorCount,
    );
  }
}
