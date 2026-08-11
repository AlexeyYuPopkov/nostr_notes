import 'package:common/presentation/tools/optional_box.dart';
import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';

final class LoginItemFormData extends Equatable {
  final OptionalBox<LoginItem> initialItem;

  final bool readonly;
  final bool canSave;


  const LoginItemFormData._({
    required this.initialItem,
    required this.readonly,
    required this.canSave,
  });

  factory LoginItemFormData.initial({required bool readonly}) {
    return LoginItemFormData._(
      initialItem: const OptionalBox(null),
      readonly: readonly,
      canSave: false,
    );
  }

  bool get isEditing => initialItem.isNotNull;

  @override
  List<Object?> get props => [initialItem, readonly, canSave];

  LoginItemFormData copyWith({
    OptionalBox<LoginItem>? initialItem,
    bool? readonly,
    bool? canSave,
  }) {
    return LoginItemFormData._(
      initialItem: initialItem ?? this.initialItem,
      readonly: readonly ?? this.readonly,
      canSave: canSave ?? this.canSave,
    );
  }
}
