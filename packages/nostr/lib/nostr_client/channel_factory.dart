import 'package:web_socket_channel/web_socket_channel.dart';

import 'relay_url_policy.dart';
import 'ws_channel.dart';

class ChannelFactory {
  const ChannelFactory();

  /// Throws [RelayUrlNotAllowedException] for `ws://` to a non-local host.
  WsChannel create(String url) {
    if (!RelayUrlPolicy.isAllowed(url)) {
      throw RelayUrlNotAllowedException(url);
    }
    return WsChannel(
      url: url,
      channel: WebSocketChannel.connect(Uri.parse(url)),
    );
  }
}
