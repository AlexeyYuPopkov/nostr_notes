import 'package:nostr_notes/auth/domain/model/note.dart';

abstract interface class CrerateSummaryHelper {
  static const _kSummaryLength = 100;

  static String create(Note note) {
    final head = note.content.length > _kSummaryLength
        ? note.content.substring(0, _kSummaryLength)
        : note.content;
    return head.replaceAll(RegExp(r'[#*`~]'), '');
  }
}
