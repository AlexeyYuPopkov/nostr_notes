import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/presentation/dashboard/header/note_list_header.dart';

ScrollMetrics _metrics({
  required double pixels,
  required double maxScrollExtent,
}) {
  return FixedScrollMetrics(
    pixels: pixels,
    minScrollExtent: 0.0,
    maxScrollExtent: maxScrollExtent,
    viewportDimension: 800.0,
    axisDirection: AxisDirection.down,
    devicePixelRatio: 1.0,
  );
}

/// The inner tab list: real content, scrolled down by [pixels].
ScrollMetrics _innerScrolled(double pixels) =>
    _metrics(pixels: pixels, maxScrollExtent: 2000.0);

/// NestedScrollView's outer position. `headerSliverBuilder` is empty, so it
/// has nothing to scroll: pixels and maxScrollExtent stay 0, yet it still
/// emits notifications into the same NotificationListener as the inner list.
ScrollMetrics _outerPinnedAtZero() =>
    _metrics(pixels: 0.0, maxScrollExtent: 0.0);

void main() {
  late NoteListHeaderVm sut;

  setUp(() => sut = NoteListHeaderVm());
  tearDown(() => sut.dispose());

  Future<BuildContext> pumpContext(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    return tester.element(find.byType(SizedBox));
  }

  void scrollUpdate(BuildContext ctx, ScrollMetrics metrics) {
    sut.onScrollNotification(
      ScrollUpdateNotification(metrics: metrics, context: ctx),
    );
  }

  void userScroll(
    BuildContext ctx,
    ScrollMetrics metrics,
    ScrollDirection direction,
  ) {
    sut.onScrollNotification(
      UserScrollNotification(
        metrics: metrics,
        context: ctx,
        direction: direction,
      ),
    );
  }

  testWidgets('starts fully visible', (tester) async {
    await pumpContext(tester);

    expect(sut.headerVisibility.value, 1.0);
  });

  testWidgets('dragging content up hides the header', (tester) async {
    final ctx = await pumpContext(tester);

    scrollUpdate(ctx, _innerScrolled(400.0));
    userScroll(ctx, _innerScrolled(400.0), ScrollDirection.reverse);

    expect(sut.headerVisibility.value, 0.0);
  });

  testWidgets('dragging content back down shows the header again', (
    tester,
  ) async {
    final ctx = await pumpContext(tester);

    userScroll(ctx, _innerScrolled(400.0), ScrollDirection.reverse);
    userScroll(ctx, _innerScrolled(300.0), ScrollDirection.forward);

    expect(sut.headerVisibility.value, 1.0);
  });

  testWidgets('a jump to the top reports offset 0, which is what renders the '
      'header open', (tester) async {
    final ctx = await pumpContext(tester);

    userScroll(ctx, _innerScrolled(400.0), ScrollDirection.reverse);
    scrollUpdate(ctx, _metrics(pixels: 0.0, maxScrollExtent: 2000.0));

    // NoteListHeader translates by offset/approxHeaderHeight, so offset 0
    // renders fully open regardless of headerVisibility.
    expect(sut.scrollOffset.value, 0.0);
  });

  testWidgets("the inactive tab's list must not re-open a hidden header", (
    tester,
  ) async {
    final ctx = await pumpContext(tester);

    scrollUpdate(ctx, _innerScrolled(400.0));
    userScroll(ctx, _innerScrolled(400.0), ScrollDirection.reverse);
    expect(sut.headerVisibility.value, 0.0);

    // TabBarView keeps both tabs alive; the one you are not looking at is
    // still parked at the top and reports into the same listener.
    scrollUpdate(ctx, _metrics(pixels: 0.0, maxScrollExtent: 2000.0));

    expect(sut.headerVisibility.value, 0.0);
  });

  testWidgets('the outer NestedScrollView position must not re-open a hidden '
      'header', (tester) async {
    final ctx = await pumpContext(tester);

    scrollUpdate(ctx, _innerScrolled(400.0));
    userScroll(ctx, _innerScrolled(400.0), ScrollDirection.reverse);
    expect(sut.headerVisibility.value, 0.0);

    scrollUpdate(ctx, _outerPinnedAtZero());

    expect(
      sut.headerVisibility.value,
      0.0,
      reason:
          'a position that cannot scroll says nothing about where the '
          'user is in the list it coordinates',
    );
    expect(sut.scrollOffset.value, 400.0);
  });
}
