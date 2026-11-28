import 'package:common/domain/model/user.dart';
import 'package:equatable/equatable.dart';
import 'package:webrtc_call/webrtc_call.dart';

final class CallData extends Equatable {
  final User peer;
  final CallMedia media;

  const CallData({required this.peer, required this.media});

  CallData copyWith({User? peer}) =>
      CallData(peer: peer ?? this.peer, media: media);

  @override
  List<Object?> get props => [peer, media];
}
