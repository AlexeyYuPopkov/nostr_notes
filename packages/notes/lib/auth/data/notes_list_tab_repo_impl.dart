import 'package:nostr_notes/auth/domain/repo/notes_list_tab_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class NotesListTabRepoImpl implements NotesListTabRepo {
  final SharedPreferences _prefs;
  static const _key = 'notes_list_tab_index';

  const NotesListTabRepoImpl(this._prefs);

  @override
  int getTabIndex() => _prefs.getInt(_key) ?? 0;

  @override
  Future<void> setTabIndex(int index) => _prefs.setInt(_key, index);
}
