import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/usecase/delete_acc_usecase.dart';

sealed class DelAccEvent extends Equatable {
  const DelAccEvent();

  const factory DelAccEvent.delete() = DelEvent;
  const factory DelAccEvent.didUpdateStatus(DeleteAccStatus status) =
      DidUpdateStatusEvent;

  @override
  List<Object?> get props => const [];
}

final class DelEvent extends DelAccEvent {
  const DelEvent();
}

final class DidUpdateStatusEvent extends DelAccEvent {
  final DeleteAccStatus status;
  const DidUpdateStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}
