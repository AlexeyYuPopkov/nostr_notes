import 'package:chat/auth/chat/domain/models/chat_message_body.dart';
import 'package:flutter_test/flutter_test.dart';

import 'my_sent_messages.dart';

/// Usage: Then {'Alice'} is told the call was {'declined'}
///
/// `declined` or `cancelled`.
Future<void> isToldTheCallWas(
  WidgetTester tester,
  String contact,
  String outcome,
) async {
  switch (outcome) {
    case 'declined':
      await waitForMyMessageTo<ChatCallDecline>(tester, contact);
    case 'cancelled':
      await waitForMyMessageTo<ChatCallCancel>(tester, contact);
    default:
      fail('Unknown outcome "$outcome"');
  }
}
