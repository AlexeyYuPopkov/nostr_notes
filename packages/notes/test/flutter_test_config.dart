import 'dart:async';

import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  LeakTesting.enable();

  // flutter_slidable 4.0.3's SlidableController.dispose() only disposes
  // _animationController and direction — it never disposes endGesture,
  // dismissGesture, resizeRequest, or actionPaneType (confirmed by reading
  // package:flutter_slidable/src/controller.dart:371-377). Every Slidable
  // widget (NotesListCard, account_list_card.dart) leaks these 4 on
  // disposal as a result — nothing we can fix on our side. Revisit once
  // the package ships a fix.
  LeakTesting.settings = LeakTesting.settings.withIgnored(
    notDisposed: {
      'ValueNotifier<EndGesture?>': null,
      '_ValueNotifier<DismissGesture?>': null,
      'ValueNotifier<ResizeRequest?>': null,
      'ValueNotifier<ActionPaneType>': null,
    },
  );

  await testMain();
}
