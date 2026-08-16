import 'package:equatable/equatable.dart';

sealed class LoginItemFormEvent extends Equatable {
  const LoginItemFormEvent();

  const factory LoginItemFormEvent.initial() = InitialEvent;

  /// Any field controller changed; recomputes [LoginItemFormData.canSave].
  const factory LoginItemFormEvent.fieldsChanged() = FieldsChangedEvent;

  const factory LoginItemFormEvent.save() = SaveEvent;

  const factory LoginItemFormEvent.toggleMode() = ToggleModeEvent;

  const factory LoginItemFormEvent.delete() = DeleteEvent;

  const factory LoginItemFormEvent.willExport() = WillExportEvent;

  const factory LoginItemFormEvent.export({
    required String password,
    String? fileName,
  }) = ExportEvent;

  /// Toggles the password generator panel open/closed. The panel owns its
  /// own style selection and generation locally — see
  /// `LoginItemFormGenPassPanel` — so this carries no payload.
  const factory LoginItemFormEvent.willGenPassAppear() = WillGenPassAppearEvent;

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

final class DeleteEvent extends LoginItemFormEvent {
  const DeleteEvent();
}

final class WillExportEvent extends LoginItemFormEvent {
  const WillExportEvent();
}

final class ExportEvent extends LoginItemFormEvent {
  final String password;
  final String? fileName;

  const ExportEvent({required this.password, this.fileName});

  @override
  List<Object?> get props => [password, fileName];
}

final class WillGenPassAppearEvent extends LoginItemFormEvent {
  const WillGenPassAppearEvent();
}
