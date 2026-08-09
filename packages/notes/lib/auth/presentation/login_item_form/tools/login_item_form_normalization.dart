/// Matches an explicit `scheme://` prefix. Deliberately not `Uri.hasScheme`:
/// for "apple.com:8080" the RFC treats "apple.com" as a valid scheme token
/// (and "8080" as the path), so `hasScheme` is true and the host:port input
/// would skip normalization — leaving it unopenable by `canLaunchUrl`.
final _schemePrefix = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.\-]*://');

/// Save-time normalization for login item form fields; mixed into
/// `LoginItemFormBloc`.
mixin LoginItemFormNormalization {
  /// "apple.com" → "https://apple.com"; input that already carries an
  /// explicit `scheme://` (and empty input) passes through unchanged apart
  /// from trimming.
  ///
  /// Without a scheme `Uri.tryParse` yields no host, so `canLaunchUrl` in
  /// `LoginItemGoIcon` would always fail, permanently disabling the go
  /// button for the saved item.
  String normalizedWebsiteUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || _schemePrefix.hasMatch(trimmed)) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  /// The title persisted on save: the explicit title when present, else the
  /// website host (sans `www.`), else the username — so list cards never
  /// render nameless. Expects [websiteUrl] to be already normalized (a
  /// scheme-less string has no parseable host).
  String deriveTitle({
    required String title,
    required String websiteUrl,
    required String username,
  }) {
    final trimmed = title.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }

    final host = Uri.tryParse(websiteUrl.trim())?.host ?? '';
    if (host.isNotEmpty) {
      return host.startsWith('www.') ? host.substring(4) : host;
    }

    return username.trim();
  }
}
