import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/presentation/login_item_form/bloc/login_item_form_data.dart';

sealed class LoginItemFormState extends Equatable {
  final LoginItemFormData data;

  const LoginItemFormState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory LoginItemFormState.common({required LoginItemFormData data}) =
      CommonState;

  const factory LoginItemFormState.loading({required LoginItemFormData data}) =
      LoadingState;

  const factory LoginItemFormState.error({
    required LoginItemFormData data,
    required Object e,
  }) = ErrorState;

  const factory LoginItemFormState.didSave({
    required LoginItemFormData data,
    required LoginItem item,
  }) = DidSaveState;
}

final class CommonState extends LoginItemFormState {
  const CommonState({required super.data});
}

final class LoadingState extends LoginItemFormState {
  const LoadingState({required super.data});
}

final class ErrorState extends LoginItemFormState {
  final Object e;
  const ErrorState({required super.data, required this.e});
}

final class DidSaveState extends LoginItemFormState {
  final LoginItem item;
  const DidSaveState({required super.data, required this.item});
}
