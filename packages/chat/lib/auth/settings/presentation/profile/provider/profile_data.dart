import 'package:chat/auth/settings/domain/models/picture_url.dart';
import 'package:chat/auth/settings/domain/models/profile_fields.dart';
import 'package:common/domain/model/user.dart';
import 'package:equatable/equatable.dart';
import 'package:nostr/key_tool/key_tool.dart';

final class ProfileData extends Equatable {
  final User profile;
  final ProfileFields saved;
  final ProfileFields draft;

  /// Bumped when [draft] is reset from the store, so the form re-reads it.
  final int formRevision;

  const ProfileData._({
    required this.profile,
    required this.saved,
    required this.draft,
    required this.formRevision,
  });

  factory ProfileData.initial() => const ProfileData._(
    profile: User(pubkey: ''),
    saved: ProfileFields(),
    draft: ProfileFields(),
    formRevision: 0,
  );

  String get pubkey => profile.pubkey;

  String get npub => pubkey.isEmpty ? '' : KeyTool.npubKey(pubkey);

  bool get isPictureValid => PictureUrl.isValidOrEmpty(draft.picture);

  bool get hasChanges => draft.trimmed() != saved;

  bool get canSave => hasChanges && isPictureValid;

  bool get isDraftUntouched => draft == saved;

  /// The picture to show in the avatar: the draft link once it is valid,
  /// otherwise the saved one.
  String get previewPictureUrl {
    final draftPicture = draft.picture.trim();
    return isPictureValid && draftPicture.isNotEmpty
        ? draftPicture
        : saved.picture;
  }

  ProfileData copyWith({
    User? profile,
    ProfileFields? saved,
    ProfileFields? draft,
    int? formRevision,
  }) {
    return ProfileData._(
      profile: profile ?? this.profile,
      saved: saved ?? this.saved,
      draft: draft ?? this.draft,
      formRevision: formRevision ?? this.formRevision,
    );
  }

  @override
  List<Object?> get props => [profile, saved, draft, formRevision];
}
