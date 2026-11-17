abstract final class RelayUrlPolicy {
  static const cleartextHosts = {'localhost', '127.0.0.1', '10.0.2.2'};

  static bool isAllowed(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return false;
    }
    return switch (uri.scheme) {
      'wss' => true,
      'ws' => cleartextHosts.contains(uri.host),
      _ => false,
    };
  }
}

final class RelayUrlNotAllowedException implements Exception {
  const RelayUrlNotAllowedException(this.url);

  final String url;

  @override
  String toString() => 'RelayUrlNotAllowedException: $url';
}
