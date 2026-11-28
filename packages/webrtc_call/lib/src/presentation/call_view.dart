import 'package:material_ui/material_ui.dart';

import '../domain/signaling_message.dart';
import '../session/call_stats.dart';
import '../session/peer_connection_session.dart';
import 'call_video_view.dart';

/// Texts of [CallView]; the app passes localized ones.
final class CallViewLabels {
  final String calling;
  final String connecting;
  final String connected;
  final String reconnecting;
  final String ended;
  final String noAnswer;
  final String declined;
  final String failed;
  final String mute;
  final String unmute;
  final String speakerOn;
  final String speakerOff;
  final String switchCamera;
  final String cameraOff;
  final String cameraOn;
  final String hangUp;

  const CallViewLabels({
    this.calling = 'Calling…',
    this.connecting = 'Connecting…',
    this.connected = 'Connected',
    this.reconnecting = 'Reconnecting…',
    this.ended = 'Call ended',
    this.noAnswer = 'No answer',
    this.declined = 'Declined',
    this.failed = 'Call failed',
    this.mute = 'Mute',
    this.unmute = 'Unmute',
    this.speakerOn = 'Speaker on',
    this.speakerOff = 'Speaker off',
    this.switchCamera = 'Switch camera',
    this.cameraOff = 'Turn camera off',
    this.cameraOn = 'Turn camera on',
    this.hangUp = 'Hang up',
  });

  /// [endReason] tells how an [CallPhase.idle] call ended.
  String status(CallPhase phase, CallEndReason? endReason) => switch (phase) {
    CallPhase.idle => switch (endReason) {
      CallEndReason.noAnswer => noAnswer,
      CallEndReason.declined => declined,
      CallEndReason.failed => failed,
      CallEndReason.hungUp || CallEndReason.remoteHungUp || null => ended,
    },
    CallPhase.calling => calling,
    CallPhase.connecting => connecting,
    CallPhase.connected => connected,
    CallPhase.reconnecting => reconnecting,
  };
}

/// The screen of the current call in [session]: video or, for an audio call,
/// [peerName] and the call state, with the call controls below.
final class CallView extends StatelessWidget {
  final PeerConnectionSession session;
  final String peerName;
  final CallViewLabels labels;

  /// Shows how the call reaches the peer (`relay` means TURN), round trip and
  /// bitrates; for checking the network setup, not for end users.
  final bool showsConnectionStats;

  const CallView({
    super.key,
    required this.session,
    required this.peerName,
    this.labels = const CallViewLabels(),
    this.showsConnectionStats = false,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: ValueListenableBuilder(
        valueListenable: session.media,
        builder: (context, media, _) {
          final isVideo = media == CallMedia.video;
          return Stack(
            children: [
              if (isVideo) ...[
                Positioned.fill(
                  child: CallVideoView(renderer: session.remoteRenderer),
                ),
                _LocalPreview(session: session),
                Positioned(
                  top: 16,
                  left: 16,
                  right: _LocalPreview.size.width + 32,
                  child: _PeerStatus(
                    session: session,
                    peerName: peerName,
                    labels: labels,
                    showsConnectionStats: showsConnectionStats,
                    alignment: CrossAxisAlignment.start,
                  ),
                ),
              ] else
                Align(
                  alignment: const Alignment(0, -0.4),
                  child: _PeerStatus(
                    session: session,
                    peerName: peerName,
                    labels: labels,
                    showsConnectionStats: showsConnectionStats,
                    alignment: CrossAxisAlignment.center,
                    showAvatar: true,
                  ),
                ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 32,
                child: _CallControls(
                  session: session,
                  labels: labels,
                  isVideo: isVideo,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

final class _LocalPreview extends StatelessWidget {
  static const size = Size(120, 160);

  final PeerConnectionSession session;

  const _LocalPreview({required this.session});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      width: size.width,
      height: size.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ListenableBuilder(
          listenable: Listenable.merge([
            session.usingFrontCamera,
            session.cameraEnabled,
          ]),
          builder: (context, _) => session.cameraEnabled.value
              ? CallVideoView(
                  renderer: session.localRenderer,
                  mirror: session.usingFrontCamera.value,
                )
              : const ColoredBox(
                  color: Colors.black54,
                  child: Center(
                    child: Icon(Icons.videocam_off, color: Colors.white70),
                  ),
                ),
        ),
      ),
    );
  }
}

final class _PeerStatus extends StatelessWidget {
  static const _avatarRadius = 48.0;

  final PeerConnectionSession session;
  final String peerName;
  final CallViewLabels labels;
  final bool showsConnectionStats;
  final CrossAxisAlignment alignment;
  final bool showAvatar;

  const _PeerStatus({
    required this.session,
    required this.peerName,
    required this.labels,
    required this.showsConnectionStats,
    required this.alignment,
    this.showAvatar = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final initial = peerName.isEmpty ? '?' : peerName.characters.first;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        if (showAvatar) ...[
          CircleAvatar(
            radius: _avatarRadius,
            child: Text(initial.toUpperCase(), style: textTheme.headlineLarge),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          peerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 4),
        ListenableBuilder(
          listenable: Listenable.merge([
            session.phase,
            session.lastEndReason,
            session.stats,
          ]),
          builder: (context, _) {
            final stats = showsConnectionStats ? session.stats.value : null;
            final statusStyle = textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            );
            return Column(
              crossAxisAlignment: alignment,
              children: [
                Semantics(
                  identifier: 'call_view.status',
                  child: Text(_status(stats), style: statusStyle),
                ),
                if (stats != null)
                  Semantics(
                    identifier: 'call_view.stats',
                    child: Text(
                      _statsLine(stats),
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _status(CallStats? stats) {
    final status = labels.status(
      session.phase.value,
      session.lastEndReason.value,
    );
    final candidateType = stats?.localCandidateType;
    return candidateType == null ? status : '$status · $candidateType';
  }

  static String _statsLine(CallStats stats) {
    String orDash(int? value) => value?.toString() ?? '–';
    return 'RTT ${orDash(stats.roundTripTime?.inMilliseconds)} ms'
        ' · ↑ ${orDash(stats.outgoingKbps)}'
        ' ↓ ${orDash(stats.incomingKbps)} kbps';
  }
}

final class _CallControls extends StatelessWidget {
  final PeerConnectionSession session;
  final CallViewLabels labels;
  final bool isVideo;

  const _CallControls({
    required this.session,
    required this.labels,
    required this.isVideo,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        session.microphoneMuted,
        session.speakerOn,
        session.cameraEnabled,
      ]),
      builder: (context, _) {
        final isMuted = session.microphoneMuted.value;
        final isSpeakerOn = session.speakerOn.value;
        final isCameraOn = session.cameraEnabled.value;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ControlButton(
              identifier: 'call_view.mute',
              tooltip: isMuted ? labels.unmute : labels.mute,
              icon: isMuted ? Icons.mic_off : Icons.mic,
              isActive: isMuted,
              onPressed: () => session.setMicrophoneMuted(!isMuted),
            ),
            _ControlButton(
              identifier: 'call_view.speaker',
              tooltip: isSpeakerOn ? labels.speakerOff : labels.speakerOn,
              icon: isSpeakerOn ? Icons.volume_up : Icons.volume_down,
              isActive: isSpeakerOn,
              onPressed: () => session.setSpeakerOn(!isSpeakerOn),
            ),
            if (isVideo)
              _ControlButton(
                identifier: 'call_view.camera',
                tooltip: isCameraOn ? labels.cameraOff : labels.cameraOn,
                icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
                isActive: !isCameraOn,
                onPressed: () => session.setCameraEnabled(!isCameraOn),
              ),
            if (isVideo)
              _ControlButton(
                identifier: 'call_view.switch_camera',
                tooltip: labels.switchCamera,
                icon: Icons.cameraswitch,
                onPressed: session.switchCamera,
              ),
            Semantics(
              identifier: 'call_view.hang_up',
              child: FloatingActionButton(
                heroTag: null,
                tooltip: labels.hangUp,
                backgroundColor: Colors.red,
                onPressed: session.hangUp,
                child: const Icon(Icons.call_end, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

final class _ControlButton extends StatelessWidget {
  final String identifier;
  final String tooltip;
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.identifier,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: identifier,
      toggled: isActive,
      child: IconButton.filled(
        tooltip: tooltip,
        iconSize: 28,
        style: IconButton.styleFrom(
          backgroundColor: isActive ? Colors.white : Colors.white24,
          foregroundColor: isActive ? Colors.black : Colors.white,
        ),
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }
}
