import 'package:flutter_test/flutter_test.dart';

import 'invited_me_to_a_call.dart';

/// Usage: Given {'Alice'} invited me to a call {'video'} {2} minutes ago
Future<void> invitedMeToACallMinutesAgo(
  WidgetTester tester,
  String contact,
  String media,
  int minutes,
) => publishCallInvite(
  contact: contact,
  media: media,
  at: DateTime.now().subtract(Duration(minutes: minutes)),
);
