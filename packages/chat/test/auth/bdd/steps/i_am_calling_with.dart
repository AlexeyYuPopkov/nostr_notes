import 'package:chat/auth/call/domain/usecase/open_call_connection_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:webrtc_call/webrtc_call.dart';

import '../../../tools/webrtc/fake_call_connection.dart';
import 'chat_test_world.dart';

/// Usage: Then I am calling {'Alice'} with {'audio'}
Future<void> iAmCallingWith(
  WidgetTester tester,
  String contact,
  String media,
) async {
  final calls =
      GetIt.I.get<OpenCallConnectionUsecase>() as NeverConnectingCalls;
  final session = calls.lastSession;
  expect(session, isNotNull, reason: 'no call was started');
  expect(
    session!.peerId.value,
    ChatTestWorld.current.contact(contact).publicKey,
  );
  expect(session.media.value, CallMedia.values.byName(media));
  expect(session.phase.value, CallPhase.calling);
}
