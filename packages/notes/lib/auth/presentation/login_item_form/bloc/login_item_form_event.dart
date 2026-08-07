import 'package:equatable/equatable.dart';

sealed class LoginItemFormEvent extends Equatable {
  const LoginItemFormEvent();

  const factory LoginItemFormEvent.initial() = InitialEvent;

  /// Any field controller changed; recomputes [LoginItemFormData.canSave].
  const factory LoginItemFormEvent.fieldsChanged() = FieldsChangedEvent;

  const factory LoginItemFormEvent.save() = SaveEvent;

  const factory LoginItemFormEvent.toggleMode() = ToggleModeEvent;

  @override
  List<Object?> get props => [runtimeType];
}

final class InitialEvent extends LoginItemFormEvent {
  const InitialEvent();
}

final class FieldsChangedEvent extends LoginItemFormEvent {
  const FieldsChangedEvent();
}

final class SaveEvent extends LoginItemFormEvent {
  const SaveEvent();
}

final class ToggleModeEvent extends LoginItemFormEvent {
  const ToggleModeEvent();
}
