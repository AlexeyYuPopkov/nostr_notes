import 'dart:async';

import 'package:chat/auth/call/presentation/incoming_call/provider/incoming_call_data.dart';
import 'package:chat/auth/call/presentation/incoming_call/provider/incoming_call_provider.dart';
import 'package:chat/auth/chat/presentation/common/user_title.dart';
import 'package:chat/l10n/localization.dart';
import 'package:common/presentation/account_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:webrtc_call/webrtc_call.dart';

abstract interface class IncomingCallScreenCoordinator {
  Future<void> onAccepted(
    BuildContext context, {
    required String callerPubkey,
    required CallMedia media,
  });
}

/// Rings for an invite until it is answered or the caller gives up.
final class IncomingCallScreen extends ConsumerStatefulWidget {
  static const acceptSemanticsId = 'IncomingCallScreen.accept';
  static const declineSemanticsId = 'IncomingCallScreen.decline';

  final String callerPubkey;
  final String callId;
  final CallMedia media;

  /// When the caller stops waiting; the screen closes then.
  final DateTime expiresAt;
  final IncomingCallScreenCoordinator coordinator;

  const IncomingCallScreen({
    super.key,
    required this.callerPubkey,
    required this.callId,
    required this.media,
    required this.expiresAt,
    required this.coordinator,
  });

  @override
  ConsumerState<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

final class _IncomingCallScreenState extends ConsumerState<IncomingCallScreen> {
  static const _avatarSize = 96.0;

  Timer? _expiry;

  @override
  void initState() {
    super.initState();
    _expiry = Timer(widget.expiresAt.difference(DateTime.now()), _close);
  }

  @override
  void dispose() {
    _expiry?.cancel();
    super.dispose();
  }

  IncomingCallProviderProvider get _provider =>
      incomingCallProviderProvider(widget.callerPubkey, widget.callId);

  void _close() {
    if (mounted) unawaited(Navigator.of(context).maybePop());
  }

  void _decline() {
    // Best effort: the caller's wait times out anyway if this is lost.
    unawaited(
      ref.read(_provider.notifier).decline().then((_) {}, onError: (_) {}),
    );
    _close();
  }

  void _onData(IncomingCallData? previous, IncomingCallData next) {
    if (next.isCancelled && previous?.isCancelled != true) _close();
  }

  void _accept() {
    _expiry?.cancel();
    unawaited(
      widget.coordinator.onAccepted(
        context,
        callerPubkey: widget.callerPubkey,
        media: widget.media,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(_provider, _onData);
    final caller = ref.watch(_provider).caller;
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(),
              AccountAvatar(
                pubkey: caller.pubkey,
                size: _avatarSize,
                pictureUrl: caller.picture,
              ),
              const SizedBox(height: 16),
              Text(
                caller.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(switch (widget.media) {
                CallMedia.audio => l10n.incomingCallAudio,
                CallMedia.video => l10n.incomingCallVideo,
              }, style: textTheme.bodyMedium?.copyWith(color: Colors.white70)),
              const Spacer(flex: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AnswerButton(
                    semanticsId: IncomingCallScreen.declineSemanticsId,
                    tooltip: l10n.incomingCallDecline,
                    icon: Icons.call_end,
                    color: Colors.red,
                    onPressed: _decline,
                  ),
                  _AnswerButton(
                    semanticsId: IncomingCallScreen.acceptSemanticsId,
                    tooltip: l10n.incomingCallAccept,
                    icon: switch (widget.media) {
                      CallMedia.audio => Icons.call,
                      CallMedia.video => Icons.videocam,
                    },
                    color: Colors.green,
                    onPressed: _accept,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _AnswerButton extends StatelessWidget {
  final String semanticsId;
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _AnswerButton({
    required this.semanticsId,
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: semanticsId,
      child: FloatingActionButton(
        heroTag: null,
        tooltip: tooltip,
        backgroundColor: color,
        onPressed: onPressed,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
