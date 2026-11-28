import 'package:chat/auth/call/domain/usecase/open_call_connection_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../../tools/webrtc/fake_call_connection.dart';

/// Usage: And calls never connect
///
/// No signaling server, camera or microphone: a call stays at "Calling…".
Future<void> callsNeverConnect(WidgetTester tester) async {
  GetIt.I.unregister<OpenCallConnectionUsecase>();
  GetIt.I.registerSingleton<OpenCallConnectionUsecase>(NeverConnectingCalls());
}
