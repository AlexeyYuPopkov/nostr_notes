import 'dart:async';

import 'package:chat/auth/chat/domain/models/chat_message.dart';
import 'package:chat/auth/chat/domain/models/chat_message_body.dart';
import 'package:chat/auth/chat/domain/usecase/watch_incoming_call_invites_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:material_ui/material_ui.dart';
import 'package:webrtc_call/webrtc_call.dart';

abstract interface class IncomingCallListenerCoordinator {
  Future<void> onIncomingCall(
    BuildContext context, {
    required String callerPubkey,
    required String callId,
    required CallMedia media,
    required DateTime expiresAt,
  });
}

/// Rings for fresh call invites while [child] is on screen.
final class IncomingCallListener extends StatefulWidget {
  final IncomingCallListenerCoordinator coordinator;
  final Widget child;

  const IncomingCallListener({
    super.key,
    required this.coordinator,
    required this.child,
  });

  @override
  State<IncomingCallListener> createState() => _IncomingCallListenerState();
}

final class _IncomingCallListenerState extends State<IncomingCallListener> {
  late final _vm = IncomingCallListenerVm();
  StreamSubscription<IncomingCallInvite>? _invites;

  @override
  void initState() {
    super.initState();
    _invites = _vm.invites.listen(_onInvite);
  }

  @override
  void dispose() {
    unawaited(_invites?.cancel());
    super.dispose();
  }

  void _onInvite(IncomingCallInvite invite) {
    if (!mounted) return;
    unawaited(
      widget.coordinator.onIncomingCall(
        context,
        callerPubkey: invite.callerPubkey,
        callId: invite.callId,
        media: invite.media,
        expiresAt: invite.expiresAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

final class IncomingCallInvite {
  final String callerPubkey;
  final String callId;
  final CallMedia media;
  final DateTime expiresAt;

  const IncomingCallInvite({
    required this.callerPubkey,
    required this.callId,
    required this.media,
    required this.expiresAt,
  });
}

final class IncomingCallListenerVm {
  final WatchIncomingCallInvitesUsecase _watchInvites;

  IncomingCallListenerVm({WatchIncomingCallInvitesUsecase? watchInvites})
    : _watchInvites = watchInvites ?? GetIt.I.get();

  /// Without a session nothing can ring, so its error ends the stream quietly.
  Stream<IncomingCallInvite> get invites => _watchInvites
      .execute()
      .handleError((Object _) {})
      .expand((message) => [?_toInvite(message)]);

  static IncomingCallInvite? _toInvite(ChatMessage message) =>
      switch (message.body) {
        ChatCallInvite(:final callId, :final media) => IncomingCallInvite(
          callerPubkey: message.authorPubkey,
          callId: callId,
          media: media,
          expiresAt: message.publishedAt.add(
            PeerConnectionSession.defaultAnswerTimeout,
          ),
        ),
        ChatText() || ChatCallNotice() => null,
      };
}
