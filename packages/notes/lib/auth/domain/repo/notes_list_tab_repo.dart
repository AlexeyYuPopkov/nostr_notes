abstract interface class NotesListTabRepo {
  int getTabIndex();
  Future<void> setTabIndex(int index);
}
