import 'package:equatable/equatable.dart';

import 'profile_data.dart';

sealed class ProfileState extends Equatable {
  final ProfileData data;
  const ProfileState({required this.data});

  @override
  List<Object?> get props => [data];
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading({required super.data});
}

final class ProfileCommon extends ProfileState {
  const ProfileCommon({required super.data});
}

final class ProfileSaving extends ProfileState {
  const ProfileSaving({required super.data});
}

final class ProfileSaved extends ProfileState {
  const ProfileSaved({required super.data});
}

final class ProfileError extends ProfileState {
  final Object error;
  const ProfileError({required super.data, required this.error});

  @override
  List<Object?> get props => [data, error];
}
