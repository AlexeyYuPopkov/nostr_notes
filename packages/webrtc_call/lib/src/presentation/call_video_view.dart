import 'package:flutter/widgets.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// [RTCVideoView] that shows the video once [renderer] gets a stream.
///
/// `RTCVideoView` decides between its `Texture` and the placeholder only in
/// its own build (flutter_webrtc 1.6.3, `rtc_video_view_impl.dart`), so a view
/// built before `srcObject` is set stays blank. Rebuilding it on every
/// renderer change picks the stream up.
final class CallVideoView extends StatelessWidget {
  final RTCVideoRenderer renderer;
  final bool mirror;

  const CallVideoView({super.key, required this.renderer, this.mirror = false});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: renderer,
      builder: (context, _, _) => RTCVideoView(
        renderer,
        mirror: mirror,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      ),
    );
  }
}
