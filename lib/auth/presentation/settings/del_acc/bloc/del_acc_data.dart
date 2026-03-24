import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/usecase/delete_acc_usecase.dart';

final class DelAccData extends Equatable {
  final DeleteAccStatus? status;
  const DelAccData._({required this.status});

  factory DelAccData.initial() {
    return const DelAccData._(status: null);
  }

  @override
  List<Object?> get props => [status];

  DelAccData copyWith({DeleteAccStatus? status}) {
    return DelAccData._(status: status ?? this.status);
  }
}
