import 'package:equatable/equatable.dart';

sealed class HomeScreenEvent extends Equatable {
  const HomeScreenEvent();

  // const factory HomeScreenEvent.initial() = InitialEvent;
  const factory HomeScreenEvent.selectNote({
    required String selectedNoteDTag,
    required bool isMobile,
  }) = SelectNoteEvent;

  @override
  List<Object?> get props => const [];
}

// final class InitialEvent extends HomeScreenEvent {
//   const InitialEvent();
// }

final class SelectNoteEvent extends HomeScreenEvent {
  final String selectedNoteDTag;
  final bool isMobile;
  const SelectNoteEvent(
      {required this.selectedNoteDTag, required this.isMobile});
}
