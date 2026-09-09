/// One-shot commands broadcast from [DashboardBloc] to its per-tab child
/// blocs (`NotesListBloc`, `AccsBloc`, ...). Unlike [DashboardState], these
/// are not persisted view state — each child reacts once per command rather
/// than holding it.
enum DashboardCommand {
  /// The user tapped the refresh button.
  refresh,

  /// The app returned to the foreground.
  resumed,
}
