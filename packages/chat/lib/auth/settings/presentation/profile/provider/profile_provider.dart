import 'package:chat/auth/settings/domain/models/profile_fields.dart';
import 'package:chat/auth/settings/domain/usecase/get_current_profile_usecase.dart';
import 'package:chat/auth/settings/domain/usecase/update_profile_usecase.dart';
import 'package:common/domain/model/user.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'profile_data.dart';
import 'profile_state.dart';

part 'profile_provider.g.dart';

@riverpod
final class ProfileProvider extends _$ProfileProvider {
  late final GetCurrentProfileUsecase _getUsecase = GetIt.I.get();
  late final UpdateProfileUsecase _updateUsecase = GetIt.I.get();

  ProfileData get _data => state.data;

  @override
  ProfileState build() {
    final subscription = _getUsecase.execute().listen(
      _onProfile,
      onError: _onError,
    );
    ref.onDispose(subscription.cancel);

    return ProfileLoading(data: ProfileData.initial());
  }

  void onNameChanged(String value) =>
      _updateDraft(_data.draft.copyWith(name: value));

  void onDisplayNameChanged(String value) =>
      _updateDraft(_data.draft.copyWith(displayName: value));

  void onPictureChanged(String value) =>
      _updateDraft(_data.draft.copyWith(picture: value));

  Future<void> save() async {
    if (state is ProfileSaving || !_data.canSave) {
      return;
    }

    state = ProfileSaving(data: _data);
    try {
      await _updateUsecase.execute(_data.draft);
      if (ref.mounted) {
        state = ProfileSaved(data: _data);
      }
    } catch (error) {
      if (ref.mounted) {
        state = ProfileError(data: _data, error: error);
      }
    }
  }

  void _updateDraft(ProfileFields draft) {
    _emit(_data.copyWith(draft: draft));
  }

  void _onProfile(User profile) {
    final saved = ProfileFields.fromUser(profile);
    final followsStore = _data.isDraftUntouched && saved != _data.saved;

    _emit(
      _data.copyWith(
        profile: profile,
        saved: saved,
        draft: followsStore ? saved : null,
        formRevision: followsStore ? _data.formRevision + 1 : null,
      ),
    );
  }

  void _emit(ProfileData data) {
    state = switch (state) {
      ProfileSaving() => ProfileSaving(data: data),
      _ => ProfileCommon(data: data),
    };
  }

  void _onError(Object error) {
    state = ProfileError(data: _data, error: error);
  }
}
