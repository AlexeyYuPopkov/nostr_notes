import 'package:intl/intl.dart';
import 'package:nostr_notes/app/l10n/app_localizations.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';

final class DateSection {
  final String title;
  final List<NoteBase> notes;

  const DateSection({required this.title, required this.notes});
}

List<DateSection> groupNotesByDate(
  List<NoteBase> notes,
  AppLocalizations l10n,
) {
  if (notes.isEmpty) return [];

  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  final sevenDaysAgo = startOfToday.subtract(const Duration(days: 7));
  final thirtyDaysAgo = startOfToday.subtract(const Duration(days: 30));
  final monthYearFormat = DateFormat('MMMM y');

  final Map<String, List<NoteBase>> groups = {};
  final List<String> orderedKeys = [];

  for (final note in notes) {
    final date = note.createdAt;
    final String key;

    if (date == null) {
      key = l10n.notesListSectionOther;
    } else if (date.isAfter(startOfToday) || _isSameDay(date, startOfToday)) {
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

  return [
    for (final key in orderedKeys) DateSection(title: key, notes: groups[key]!),
  ];
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
