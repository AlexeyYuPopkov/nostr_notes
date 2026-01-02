import 'dart:async';

import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_event_ok.dart';

final class NostrEventOkCompleterMap {
  final _map = <String, Completer<NostrEventOk>>{};

  String _createKey({required String relay, required String subscriptionId}) {
    return '$relay-$subscriptionId';
  }

  bool get isEmpty => _map.isEmpty;
  bool get isNotEmpty => !isEmpty;

  void add({
    required String relay,
    required NostrEvent event,
    required Completer<NostrEventOk> completer,
  }) {
    final key = _createKey(relay: relay, subscriptionId: event.id);
    _map[key] = completer;
  }

  Completer<NostrEventOk>? remove({
    required String relay,
    required String subscriptionId,
  }) {
    final key = _createKey(relay: relay, subscriptionId: subscriptionId);
    return _map.remove(key);
  }

  Future<NostrEventOk>? getFuture({
    required String relay,
    required String subscriptionId,
  }) {
    final key = _createKey(relay: relay, subscriptionId: subscriptionId);
    return _map[key]?.future;
  }
}

// final class NostrEventOkCompleterMap1 {
//   final _map = <String, Completer<NostrEventOk>>{};

//   String _createKey({required String relay, required String subscriptionId}) {
//     return '$relay-$subscriptionId';
//   }

//   bool get isEmpty => _map.isEmpty;
//   bool get isNotEmpty => !isEmpty;

//   void add({
//     required String relay,
//     required NostrEvent event,
//     required Completer<NostrEventOk> completer,
//   }) {
//     final key = _createKey(relay: relay, subscriptionId: event.id);
//     _map[key] = completer;
//   }

//   Completer<NostrEventOk>? remove({
//     required String relay,
//     required String subscriptionId,
//   }) {
//     final key = _createKey(relay: relay, subscriptionId: subscriptionId);
//     return _map.remove(key);
//   }

//   Future<NostrEventOk>? getFuture({
//     required String relay,
//     required String subscriptionId,
//   }) {
//     final key = _createKey(relay: relay, subscriptionId: subscriptionId);
//     return _map[key]?.future;
//   }
// }
