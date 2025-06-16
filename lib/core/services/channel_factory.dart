import 'package:nostr_notes/core/services/ws_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChannelFactory {
  const ChannelFactory();

  WsChannel create(String url) {
    return WsChannel(
      url: url,
      channel: WebSocketChannel.connect(
        Uri.parse(url),
      ),
    );
  }
}
