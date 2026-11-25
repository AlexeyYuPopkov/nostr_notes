import 'package:common/domain/model/user.dart';
import 'package:equatable/equatable.dart';

final class IncomingCallData extends Equatable {
  final User caller;

  /// The caller hung up before we answered.
  final bool isCancelled;

  const IncomingCallData({required this.caller, this.isCancelled = false});

  IncomingCallData copyWith({User? caller, bool? isCancelled}) =>
      IncomingCallData(
        caller: caller ?? this.caller,
        isCancelled: isCancelled ?? this.isCancelled,
      );

  @override
  List<Object?> get props => [caller, isCancelled];
}
