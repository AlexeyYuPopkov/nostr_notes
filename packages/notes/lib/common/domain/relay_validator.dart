mixin RelayValidator {
  static final _relayUrlRegex = RegExp(
    r'^wss?://'
    r'('
    r'localhost:\d{1,5}'
    r'|'
    r'[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)+' // domain
    r'(:\d{1,5})?' // optional port
    r')'
    r'(/\S*)?$', // optional path
  );

  bool isValidRelayUrl(String url) => _relayUrlRegex.hasMatch(url);

  RelayValidatorError? validateRelayUrl(String? url) {
    const startWithWss = 'ws://';
    const startWithWssSecure = 'wss://';

    final trimmedUrl = url?.trim();
    if (trimmedUrl == null || trimmedUrl.isEmpty) {
      return const RelayValidatorErrorEmpty();
    }

    if (!trimmedUrl.startsWith(startWithWss) &&
        !trimmedUrl.startsWith(startWithWssSecure)) {
      return const RelayValidatorErrorScheme();
    }

    final isValid = _relayUrlRegex.hasMatch(trimmedUrl);
    if (!isValid) {
      return const RelayValidatorErrorFormat();
    }

    return null;
  }
}

sealed class RelayValidatorError implements Exception {
  final String message;
  const RelayValidatorError(this.message);
}

final class RelayValidatorErrorEmpty extends RelayValidatorError {
  const RelayValidatorErrorEmpty() : super('URL cannot be empty');
}

final class RelayValidatorErrorScheme extends RelayValidatorError {
  const RelayValidatorErrorScheme()
    : super('URL must start with ws:// or wss://');
}

final class RelayValidatorErrorFormat extends RelayValidatorError {
  const RelayValidatorErrorFormat() : super('Invalid relay URL format');
}
