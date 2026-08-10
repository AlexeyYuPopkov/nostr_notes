import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/tools/optional_box.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/delete_login_item_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/get_login_item_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/save_login_item_usecase.dart';
import 'package:rxdart/rxdart.dart';

import '../tools/login_item_form_normalization.dart';
import 'login_item_details_params.dart';
import 'login_item_form_data.dart';
import 'login_item_form_event.dart';
import 'login_item_form_state.dart';

final class LoginItemFormBloc
    extends Bloc<LoginItemFormEvent, LoginItemFormState>
    with LoginItemFormNormalization {
  static const debounceGuard = AppDurations.short;
  final LoginItemDetailsParams pathParams;

  late final GetLoginItemUsecase _getLoginItemUsecase = DiStorage.shared
      .resolve();
  late final SaveLoginItemUsecase _saveLoginItemUsecase = DiStorage.shared
      .resolve();
  late final DeleteLoginItemUsecase _deleteLoginItemUsecase = DiStorage.shared
      .resolve();

  final titleController = TextEditingController();
  final websiteController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final notesController = TextEditingController();

  LoginItemFormData get data => state.data;

  LoginItemFormBloc({required this.pathParams})
    : super(
        LoginItemFormState.common(
          data: LoginItemFormData.initial(readonly: pathParams.readonly),
        ),
      ) {
    _setupHandlers();
    _attachControllerListeners();
    add(const LoginItemFormEvent.initial());
  }

  @override
  Future<void> close() {
    titleController.dispose();
    websiteController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    notesController.dispose();
    return super.close();
  }

  void _setupHandlers() {
    on<InitialEvent>(
      _onInitialEvent,
      transformer: (events, mapper) =>
          events.throttleTime(debounceGuard).switchMap(mapper),
    );
    on<FieldsChangedEvent>(_onFieldsChangedEvent);
    on<SaveEvent>(
      _onSaveEvent,
      transformer: (events, mapper) =>
          events.throttleTime(debounceGuard).switchMap(mapper),
    );
    on<DeleteEvent>(
      _onDeleteEvent,
      transformer: (events, mapper) =>
          events.throttleTime(debounceGuard).switchMap(mapper),
    );
    on<ToggleModeEvent>(
      _onToggleModeEvent,
      transformer: (events, mapper) =>
          events.throttleTime(debounceGuard).switchMap(mapper),
    );
  }

  void _attachControllerListeners() {
    for (final controller in [
      titleController,
      websiteController,
      usernameController,
      passwordController,
      notesController,
    ]) {
      controller.addListener(
        () => add(const LoginItemFormEvent.fieldsChanged()),
      );
    }
  }

  void _onInitialEvent(
    InitialEvent event,
    Emitter<LoginItemFormState> emit,
  ) async {
    final dTag = pathParams.id;
    if (dTag.isEmpty) {
      return;
    }

    try {
      final item = await _getLoginItemUsecase.execute(dTag: dTag);

      if (item == null) {
        throw StateError('Login item not found: $dTag');
      }
      // A decrypt failure yields a blank item with `error` set (see
      // LoginItem.locked) — filling the form from it and saving would
      // silently overwrite the still-encrypted original with blanks.
      if (item.error != null) {
        throw item.error!;
      }

      titleController.text = item.title;
      websiteController.text = item.websiteUrl;
      usernameController.text = item.username;
      passwordController.text = item.password;
      notesController.text = item.notes;

      emit(
        LoginItemFormState.common(
          data: data.copyWith(
            initialItem: OptionalBox(item),
            // Controllers now exactly mirror `item`, so there are no
            // pending changes to save yet.
            canSave: _computeCanSave(item),
          ),
        ),
      );
    } catch (e) {
      emit(LoginItemFormState.error(e: e, data: data));
    }
  }

  void _onFieldsChangedEvent(
    FieldsChangedEvent event,
    Emitter<LoginItemFormState> emit,
  ) {
    final canSave = _computeCanSave();
    if (canSave != data.canSave) {
      emit(LoginItemFormState.common(data: data.copyWith(canSave: canSave)));
    }
  }

  void _onSaveEvent(SaveEvent event, Emitter<LoginItemFormState> emit) async {
    if (!_computeCanSave()) {
      return;
    }

    try {
      emit(LoginItemFormState.loading(data: data));

      // Editing an existing item reuses its dTag/eventId/revision via
      // copyWith; a new item starts from a blank draft. Same shape either
      // way, so SaveLoginItemUsecase's isNew check (dTag.isEmpty) decides.
      final base = data.initialItem.value ?? LoginItem.draft();
      final websiteUrl = normalizedWebsiteUrl(websiteController.text);
      final saved = await _saveLoginItemUsecase.execute(
        item: base.copyWith(
          title: deriveTitle(
            title: titleController.text,
            websiteUrl: websiteUrl,
            username: usernameController.text,
          ),
          websiteUrl: websiteUrl,
          username: usernameController.text.trim(),
          // Not trimmed: leading/trailing whitespace may be intentional.
          password: passwordController.text,
          notes: notesController.text.trim(),
        ),
      );

      // Normalization may have produced values differing from what was
      // typed (derived title, https:// prefix); sync the controllers so
      // `_hasChanges` doesn't immediately report pending edits against the
      // just-saved item.
      titleController.text = saved.title;
      websiteController.text = saved.websiteUrl;

      emit(
        LoginItemFormState.didSave(
          item: saved,
          data: data.copyWith(initialItem: OptionalBox(saved), canSave: false),
        ),
      );
    } catch (e) {
      emit(LoginItemFormState.error(e: e, data: data));
    }
  }

  void _onDeleteEvent(
    DeleteEvent event,
    Emitter<LoginItemFormState> emit,
  ) async {
    final item = data.initialItem.value;
    if (item == null) {
      return;
    }

    try {
      emit(LoginItemFormState.loading(data: data));
      await _deleteLoginItemUsecase.execute(item: item);
      emit(LoginItemFormState.didDelete(data: data));
    } catch (e) {
      emit(LoginItemFormState.error(e: e, data: data));
    }
  }

  void _onToggleModeEvent(
    ToggleModeEvent event,
    Emitter<LoginItemFormState> emit,
  ) {
    emit(
      LoginItemFormState.common(data: data.copyWith(readonly: !data.readonly)),
    );
  }

  /// At least one field has text — required in addition to [_hasChanges]
  /// (title alone is no longer required: any content is enough to save).
  bool _hasAnyContent() {
    return titleController.text.trim().isNotEmpty ||
        websiteController.text.trim().isNotEmpty ||
        usernameController.text.trim().isNotEmpty ||
        passwordController.text.isNotEmpty ||
        notesController.text.trim().isNotEmpty;
  }

  /// Whether the controllers differ from [reference] (defaults to
  /// `data.initialItem.value`). With no reference (a brand-new item), any
  /// content at all counts as a change from the blank starting point.
  bool _hasChanges([LoginItem? reference]) {
    final initial = reference ?? data.initialItem.value;
    if (initial == null) {
      return _hasAnyContent();
    }
    return titleController.text.trim() != initial.title.trim() ||
        websiteController.text.trim() != initial.websiteUrl.trim() ||
        usernameController.text.trim() != initial.username.trim() ||
        passwordController.text != initial.password ||
        notesController.text.trim() != initial.notes.trim();
  }

  bool _computeCanSave([LoginItem? reference]) =>
      _hasAnyContent() && _hasChanges(reference);
}
