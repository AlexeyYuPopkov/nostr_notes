import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:nostr_notes/app/l10n/app_localizations.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';

sealed class NotesListSection extends Equatable {
  const NotesListSection();

  static List<NotesListSection> groupNotesByDate(
    List<Note> notes,
    AppLocalizations l10n,
  ) {
    if (notes.isEmpty) return [];

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final sevenDaysAgo = startOfToday.subtract(const Duration(days: 7));
    final thirtyDaysAgo = startOfToday.subtract(const Duration(days: 30));
    final monthYearFormat = DateFormat('MMMM y');

    final Map<String, List<Note>> groups = {};
    final List<String> orderedKeys = [];

    for (final note in notes) {
      final date = note.createdAt;
      final String key;

      if (date.isAfter(startOfToday) || _isSameDay(date, startOfToday)) {
        key = l10n.notesListSectionToday;
      } else if (date.isAfter(sevenDaysAgo)) {
        key = l10n.notesListSectionPrevious7Days;
      } else if (date.isAfter(thirtyDaysAgo)) {
        key = l10n.notesListSectionPrevious30Days;
      } else {
        key = monthYearFormat.format(date);
      }

      if (!groups.containsKey(key)) {
        groups[key] = [];
        orderedKeys.add(key);
      }
      groups[key]!.add(note);
    }

    final result = <NotesListSection>[];

    for (final key in orderedKeys) {
      final notes = groups[key];

      if (notes == null) {
        continue;
      }
      result.add(NotesListHeader(title: key));
      final length = notes.length - 1;
      result.addAll(
        notes
            .sorted((a, b) => b.createdAt.compareTo(a.createdAt))
            .mapIndexed(
              (index, note) => NotesListItem(
                note: note,
                position: _getPosition(index, length),
              ),
            ),
      );
    }

    return result;
  }

  static NotesListItemPosition _getPosition(int index, int length) {
    if (length == 0) {
      return NotesListItemPosition.single;
    } else if (index == 0) {
      return NotesListItemPosition.first;
    } else if (index == length) {
      return NotesListItemPosition.last;
    } else {
      return NotesListItemPosition.middle;
    }
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

final class NotesListHeader extends NotesListSection {
  final String title;

  const NotesListHeader({required this.title});

  @override
  List<Object?> get props => [title];
}

final class NotesListItem extends NotesListSection {
  final Note note;
  final NotesListItemPosition position;

  const NotesListItem({required this.note, required this.position});

  @override
  List<Object?> get props => [note.eventId, position];
}

enum NotesListItemPosition { first, middle, last, single }
