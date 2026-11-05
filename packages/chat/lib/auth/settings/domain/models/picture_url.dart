abstract final class PictureUrl {
  static const _allowedSchemes = {'https', 'http'};
  static final _whitespace = RegExp(r'\s');

  /// An empty value is valid: it means "no picture".
  static bool isValidOrEmpty(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return true;
    }
    if (_whitespace.hasMatch(trimmed)) {
      return false;
    }

    final uri = Uri.tryParse(trimmed);
    return uri != null &&
        _allowedSchemes.contains(uri.scheme.toLowerCase()) &&
        uri.host.isNotEmpty;
  }
}
