import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtc_call/webrtc_call.dart';

void main() {
  testWidgets('shows the video once the renderer gets a stream after build', (
    tester,
  ) async {
    final renderer = _FakeRenderer();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: CallVideoView(renderer: renderer),
      ),
    );
    expect(find.byType(Texture), findsNothing);

    renderer.attachStream();
    await tester.pump();

    expect(find.byType(Texture), findsOneWidget);
  });
}

/// Stands in for the native renderer, which can't run in widget tests.
final class _FakeRenderer extends RTCVideoRenderer {
  bool _hasStream = false;

  void attachStream() {
    _hasStream = true;
    value = value.copyWith(renderVideo: true);
  }

  @override
  bool get renderVideo => _hasStream;

  @override
  int? get textureId => 1;
}
