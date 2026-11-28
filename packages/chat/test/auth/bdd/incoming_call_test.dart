// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './steps/the_user_is_signed_in.dart';
import './steps/wrote_me.dart';
import './steps/calls_never_connect.dart';
import 'package:app_test_kit/bdd_steps/i_close_the_app.dart';
import './steps/invited_me_to_a_call.dart';
import './steps/i_open_the_authorized_area.dart';
import './steps/the_incoming_call_from_rings.dart';
import 'package:app_test_kit/bdd_steps/i_see_text.dart';
import './steps/invited_me_to_a_call_minutes_ago.dart';
import './steps/i_open_the_chat_with.dart';
import './steps/the_conversation_shows.dart';
import 'package:app_test_kit/bdd_steps/i_dont_see_text.dart';
import 'package:app_test_kit/bdd_steps/i_tap_semantics.dart';
import './steps/the_chat_with_shows.dart';
import './steps/is_told_the_call_was.dart';
import './steps/cancelled_the_call.dart';
import './steps/the_incoming_call_stops_ringing.dart';

void main() {
  group('''Incoming calls''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theUserIsSignedIn(tester);
      await wroteMe(tester, 'Alice', 'Hi there');
      await callsNeverConnect(tester);
    }

    Future<void> bddTearDown(WidgetTester tester) async {
      await iCloseTheApp(tester);
    }

    testWidgets('''A fresh invite rings''', (tester) async {
      try {
        await bddSetUp(tester);
        await invitedMeToACall(tester, 'Alice', 'video');
        await iOpenTheAuthorizedArea(tester);
        await theIncomingCallFromRings(tester, 'Alice');
        await iSeeText(tester, 'Incoming video call');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''An invite the caller gave up on does not ring''', (
      tester,
    ) async {
      try {
        await bddSetUp(tester);
        await invitedMeToACallMinutesAgo(tester, 'Alice', 'video', 2);
        await iOpenTheChatWith(tester, 'Alice');
        await theConversationShows(tester, 'Video call');
        await iDontSeeText(tester, 'Incoming video call');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''Accepting joins the call''', (tester) async {
      try {
        await bddSetUp(tester);
        await invitedMeToACall(tester, 'Alice', 'audio');
        await iOpenTheAuthorizedArea(tester);
        await theIncomingCallFromRings(tester, 'Alice');
        await iTapSemantics(tester, 'IncomingCallScreen.accept');
        await iSeeText(tester, 'Connecting…');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''Declining stops the ringing''', (tester) async {
      try {
        await bddSetUp(tester);
        await invitedMeToACall(tester, 'Alice', 'audio');
        await iOpenTheAuthorizedArea(tester);
        await theIncomingCallFromRings(tester, 'Alice');
        await iTapSemantics(tester, 'IncomingCallScreen.decline');
        await iDontSeeText(tester, 'Incoming audio call');
        await theChatWithShows(tester, 'Alice', 'Audio call');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''Declining tells the caller''', (tester) async {
      try {
        await bddSetUp(tester);
        await invitedMeToACall(tester, 'Alice', 'video');
        await iOpenTheAuthorizedArea(tester);
        await theIncomingCallFromRings(tester, 'Alice');
        await iTapSemantics(tester, 'IncomingCallScreen.decline');
        await isToldTheCallWas(tester, 'Alice', 'declined');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''A call the caller cancels stops ringing''', (tester) async {
      try {
        await bddSetUp(tester);
        await invitedMeToACall(tester, 'Alice', 'video');
        await iOpenTheAuthorizedArea(tester);
        await theIncomingCallFromRings(tester, 'Alice');
        await cancelledTheCall(tester, 'Alice');
        await theIncomingCallStopsRinging(tester);
        await theChatWithShows(tester, 'Alice', 'Call cancelled');
      } finally {
        await bddTearDown(tester);
      }
    });
  });
}
