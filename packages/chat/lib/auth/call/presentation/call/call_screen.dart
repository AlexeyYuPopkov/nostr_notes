import 'dart:async';

import 'package:chat/auth/call/domain/models/call_direction.dart';
import 'package:chat/auth/call/presentation/call/provider/call_provider.dart';
import 'package:chat/auth/call/presentation/call/provider/call_state.dart';
import 'package:chat/auth/chat/presentation/common/user_title.dart';
import 'package:chat/l10n/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:webrtc_call/webrtc_call.dart';

/// A call with [peerPubkey]; closes itself once the call ends.
final class CallScreen extends ConsumerWidget {
  static const closeSemanticsId = 'CallScreen.close';

  final String peerPubkey;
  final CallMedia media;
  final CallDirection direction;

  const CallScreen({
    super.key,
    required this.peerPubkey,
    required this.media,
    required this.direction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(callProviderProvider(peerPubkey, media, direction));
    final peerName = state.data.peer.title;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: switch (state) {
          CallStarting() => _CallMessage(
            peerName: peerName,
            message: context.l10n.callConnecting,
            showProgress: true,
          ),
          CallStartError() => _CallMessage(
            peerName: peerName,
            message: context.l10n.callStartError,
          ),
          CallActive(:final session) => _ActiveCall(
            session: session,
            peerName: peerName,
          ),
        },
      ),
    );
  }
}

final class _ActiveCall extends StatefulWidget {
  final PeerConnectionSession session;
  final String peerName;

  const _ActiveCall({required this.session, required this.peerName});

  @override
  State<_ActiveCall> createState() => _ActiveCallState();
}

final class _ActiveCallState extends State<_ActiveCall> {
  /// Long enough to read why the call ended, e.g. "No answer".
  static const _endReasonVisibleFor = Duration(seconds: 2);

  Timer? _closeTimer;

  @override
  void initState() {
    super.initState();
    widget.session.phase.addListener(_onPhase);
  }

  @override
  void didUpdateWidget(_ActiveCall oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session != widget.session) {
      oldWidget.session.phase.removeListener(_onPhase);
      widget.session.phase.addListener(_onPhase);
    }
  }

  @override
  void dispose() {
    widget.session.phase.removeListener(_onPhase);
    _closeTimer?.cancel();
    super.dispose();
  }

  void _onPhase() {
    final session = widget.session;
    final endReason = session.lastEndReason.value;
    final hasEnded = session.phase.value == CallPhase.idle && endReason != null;
    if (!hasEnded) return;

    if (endReason == CallEndReason.hungUp) {
      _close();
    } else {
      _closeTimer = Timer(_endReasonVisibleFor, _close);
    }
  }

  void _close() {
    if (mounted) unawaited(Navigator.of(context).maybePop());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CallView(
      session: widget.session,
      peerName: widget.peerName,
      labels: CallViewLabels(
        calling: l10n.callCalling,
        connecting: l10n.callConnecting,
        connected: l10n.callConnected,
        ended: l10n.callEnded,
        noAnswer: l10n.callNoAnswer,
        declined: l10n.callDeclined,
        failed: l10n.callFailed,
        mute: l10n.callMute,
        unmute: l10n.callUnmute,
        speakerOn: l10n.callSpeakerOn,
        speakerOff: l10n.callSpeakerOff,
        switchCamera: l10n.callSwitchCamera,
        hangUp: l10n.callHangUp,
      ),
    );
  }
}

final class _CallMessage extends StatelessWidget {
  final String peerName;
  final String message;
  final bool showProgress;

  const _CallMessage({
    required this.peerName,
    required this.message,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Spacer(),
          Text(
            peerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          if (showProgress) ...[
            const SizedBox(height: 24),
            const CircularProgressIndicator.adaptive(),
          ],
          const Spacer(),
          Semantics(
            identifier: CallScreen.closeSemanticsId,
            child: FloatingActionButton(
              heroTag: null,
              tooltip: context.l10n.callHangUp,
              backgroundColor: Colors.red,
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Icon(Icons.call_end, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
