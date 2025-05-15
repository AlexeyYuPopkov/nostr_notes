import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nostr_notes/services/model/nostr_filter.dart';
import 'package:nostr_notes/services/model/nostr_req.dart';
import 'package:nostr_notes/services/nostr_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final _client = NostrClient();

  late final channel =
      WebSocketChannel.connect(Uri.parse('wss://testing.gathr.gives'));

  StreamSubscription? _subscription;
  StreamSubscription? _subscription1;

  @override
  void initState() {
    super.initState();

    _client.addRelay('wss://relay.damus.io');
    _connect();

    // _test();
  }

  void _connect() async {
    await _client.connect();
    _subscription = _client.stream().listen((event) {
      // Handle incoming events
      print('Received event: $event');
    }, onError: (error) {
      // Handle errors
      print('Error: $error');
    }, onDone: () {
      // Handle stream completion
      print('Stream closed');
    });

    _client.sendEventToAll(
      NostrReq(
        // id: id,
        subscriptionId: 'subscriptionId',
        filters: [
          NostrFilter(
            kinds: [4],
            limit: 5,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('123'),
      ),
    );
  }
}
