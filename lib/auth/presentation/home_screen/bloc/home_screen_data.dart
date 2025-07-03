import 'package:equatable/equatable.dart';

final class HomeScreenData extends Equatable {
  final String selectedNoteDTag;
  const HomeScreenData._({required this.selectedNoteDTag});

  factory HomeScreenData.initial() {
    return const HomeScreenData._(
      selectedNoteDTag: '',
    );
  }

  @override
  List<Object?> get props => [selectedNoteDTag];

  HomeScreenData copyWith({
    String? selectedNoteDTag,
  }) {
    return HomeScreenData._(
      selectedNoteDTag: selectedNoteDTag ?? this.selectedNoteDTag,
    );
  }
}
