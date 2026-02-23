import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:nostr_notes/services/model/nostr_event_close.dart';
import 'package:nostr_notes/services/nostr_client/channel_factory.dart';
import 'package:nostr_notes/services/model/base_nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_event_eose.dart';
import 'package:nostr_notes/services/model/nostr_event_ok.dart';
import 'package:nostr_notes/services/model/nostr_req.dart';
import 'package:rxdart/rxdart.dart';

import 'ws_channel.dart';

class NostrRelay with NostrRelayEventMapper {
  NostrRelay._({required String url, required ChannelFactory channelFactory})
    : _channelFactory = channelFactory {
    _channel = _channelFactory.create(url);
    _createSubscription();
  }

  factory NostrRelay({
    required String url,
    required ChannelFactory channelFactory,
  }) {
    return NostrRelay._(url: url, channelFactory: channelFactory);
  }
  late WsChannel _channel;
  final ChannelFactory _channelFactory;

  late final _controller = StreamController<BaseNostrEvent>.broadcast();
  late StreamSubscription _channelSubscription;

  bool _isRecovering = false;
  bool _isCancelled = false;

  void _createSubscription() {
    log(
      'NostrRelay subscription created for $url; id hashCode: ${identityHashCode(this)}',
      name: 'Nostr',
    );

    try {
      _channelSubscription = _channel.stream
          .doOnCancel(() async {
            log('Channel stream cancelled for relay: $url', name: 'Nostr');
            _isCancelled = true;
            // await _recover();
          })
          .listen(
            (data) {
              try {
                final event = toNostrEvent(data);
                if (event != null && !_controller.isClosed) {
                  _controller.add(event);
                }
              } catch (e, stack) {
                log(
                  'Error processing event from relay: $url',
                  name: 'Nostr',
                  error: e,
                  stackTrace: stack,
                );
              }
            },
            onError: (e, stack) {
              log(
                'Stream error from relay: $url',
                name: 'Nostr',
                error: e,
                stackTrace: stack,
              );

              if (!_controller.isClosed) {
                _controller.addError(e, stack);
              }
            },
            onDone: () {
              log('Stream closed for relay: $url', name: 'Nostr');
              // if (!_controller.isClosed) {
              //   _controller.close();
              // }
            },
          );
    } catch (e) {
      log(
        'Exception during subscription setup for relay: $url',
        name: 'Nostr',
        error: e,
      );
      _recover();
    }
  }

  Future<void> _recover() async {
    if (_isRecovering || _controller.isClosed) {
      return;
    }
    _isRecovering = true;

    log('Attempting to recover relay: $url', name: 'Nostr');

    try {
      await _channelSubscription.cancel();
      await _channel.disconnect();

      final newChannel = _channelFactory.create(url);
      _channel = newChannel;

      _createSubscription();
      _isCancelled = false;

      log('Recovery succeeded for relay: $url', name: 'Nostr');
    } catch (e, stack) {
      log(
        'Recovery failed for relay: $url',
        name: 'Nostr',
        error: e,
        stackTrace: stack,
      );
    } finally {
      _isRecovering = false;
    }
  }

  @override
  String get url => _channel.url;

  // Future<void> get ready async {
  //   // try {
  //   //   await _channel.ready;
  //   // } catch (e) {
  //   //   rethrow;
  //   // }
  // }

  FutureOr<void> sendRequest(NostrReq req, String subscriptionId) async {
    if (_isCancelled) {
      log(
        'Cannot send request, channel is cancelled for relay: $url',
        name: 'Nostr',
      );
      _recover();
      return;
    }
    try {
      await _channel.add(req.serialized(subscriptionId));
    } catch (e) {
      log('Failed to send request to relay: $url', name: 'Nostr', error: e);
      _recover();
    }
  }

  FutureOr<void> closeRequest(NostrEventClose closeCommand) async {
    if (_isCancelled) {
      log(
        'Cannot send request, channel is cancelled for relay: $url',
        name: 'Nostr',
      );
      _recover();
      return;
    }
    try {
      await _channel.add(closeCommand.serialized());
    } catch (e) {
      log('Failed to send close to relay: $url', name: 'Nostr', error: e);
      _recover();
    }
  }

  FutureOr<void> sendEvent(NostrEvent event) async {
    if (_isCancelled) {
      log(
        'Cannot send request, channel is cancelled for relay: $url',
        name: 'Nostr',
      );
      _recover();
      return;
    }
    try {
      await _channel.add(event.serialized());
    } catch (e) {
      log('Failed to send event to relay: $url', name: 'Nostr', error: e);
      _recover();
    }
  }

  Stream<BaseNostrEvent> get eventStream => _controller.stream;

  Future<dynamic> disconnect() async {
    log('Relays disconnecting: $url', name: 'Nostr');

    await _channelSubscription.cancel();
    _isCancelled = true;
    // _channelSubscription = null;

    if (!_controller.isClosed) {
      await _controller.close();
    }
    // _controller = null;

    return _channel.disconnect();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! NostrRelay) {
      return false;
    }
    return url == other.url;
  }

  @override
  int get hashCode => url.hashCode;
}

mixin NostrRelayEventMapper {
  String get url;

  // ignore: strict_top_level_inference
  BaseNostrEvent? toNostrEvent(data) {
    return toEvent(data, url);
  }

  static BaseNostrEvent? toEvent(dynamic data, String relayUrl) {
    if (data is! String) {
      return null;
    }

    if (data.isEmpty) {
      return null;
    }

    final content = jsonDecode(data) as List?;

    if (content == null) {
      return null;
    }

    final length = content.length;

    if (length < 2) {
      return null;
    }

    final typeStr = content[0] as String?;

    if (typeStr == null || typeStr.isEmpty) {
      return null;
    }

    final type = EventType.tryFromString(typeStr);

    if (type == EventType.event) {
      try {
        if (length >= 3) {
          final payload = content[2] as Map<String, dynamic>?;

          if (payload == null || payload.isEmpty) {
            return null;
          }

          return NostrEvent.fromJson(payload);
        } else if (length >= 2) {
          final payload = content[1] as Map<String, dynamic>?;

          if (payload == null || payload.isEmpty) {
            return null;
          }

          return NostrEvent.fromJson(payload);
        }
      } catch (e) {
        return null;
      }
    }

    final subscriptionId = content[1] as String?;

    if (subscriptionId == null || subscriptionId.isEmpty) {
      return null;
    }

    if (type == EventType.closed) {
      return null;
    }

    if (type == EventType.eose) {
      return NostrEventEose(relay: relayUrl, subscriptionId: subscriptionId);
    }

    if (length < 3) {
      return null;
    }

    if (type == EventType.ok) {
      bool isOk = false;

      final src = content[2];
      if (src is bool) {
        isOk = src;
      } else if (src is String) {
        isOk = bool.tryParse(src) ?? false;
      } else {
        isOk = false;
      }

      return NostrEventOk(
        relay: relayUrl,
        isOk: isOk,
        eventId: subscriptionId,
        message: content[3] as String? ?? '',
      );
    }

    return null;
  }
}
