import 'package:common/domain/model/user.dart';
import 'package:equatable/equatable.dart';

/// The kind 0 fields the user edits. An empty string means the field is not
/// set and is removed from the published profile.
final class ProfileFields extends Equatable {
  final String name;
  final String displayName;
  final String picture;

  const ProfileFields({
    this.name = '',
    this.displayName = '',
    this.picture = '',
  });

  factory ProfileFields.fromUser(User user) => ProfileFields(
    name: user.name ?? '',
    displayName: user.displayName ?? '',
    picture: user.picture ?? '',
  );

  ProfileFields trimmed() => ProfileFields(
    name: name.trim(),
    displayName: displayName.trim(),
    picture: picture.trim(),
  );

  ProfileFields copyWith({String? name, String? displayName, String? picture}) {
    return ProfileFields(
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      picture: picture ?? this.picture,
    );
  }

  @override
  List<Object?> get props => [name, displayName, picture];
}
