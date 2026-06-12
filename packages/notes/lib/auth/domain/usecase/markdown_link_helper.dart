abstract interface class MarkdownLinkHelper {
  static final _linkPattern = RegExp(
    r'(\[[^\]]*\]\(https?://[^)]+\))|(https?://\S+)',
  );

  static String formatBareLinks(String content) {
    if (content.isEmpty) {
      return content;
    }

    final buffer = StringBuffer();
    var i = 0;

    while (i < content.length) {
      if (i + 2 < content.length && content.substring(i, i + 3) == '```') {
        final closeIndex = content.indexOf('```', i + 3);
        if (closeIndex == -1) {
          buffer.write(content.substring(i));
          i = content.length;
        } else {
          buffer.write(content.substring(i, closeIndex + 3));
          i = closeIndex + 3;
        }
      } else if (content[i] == '`') {
        final closeIndex = content.indexOf('`', i + 1);
        if (closeIndex == -1) {
          buffer.write(content.substring(i));
          i = content.length;
        } else {
          buffer.write(content.substring(i, closeIndex + 1));
          i = closeIndex + 1;
        }
      } else {
        final nextBacktick = content.indexOf('`', i);
        final textEnd = nextBacktick == -1 ? content.length : nextBacktick;
        buffer.write(_formatLinksInText(content.substring(i, textEnd)));
        i = textEnd;
      }
    }

    return buffer.toString();
  }

  static String _formatLinksInText(String text) {
    return text.replaceAllMapped(_linkPattern, (match) {
      if (match.group(1) != null) {
        return match.group(1)!;
      }
      var url = match.group(2)!;
      var suffix = '';
      while (url.isNotEmpty && _isTrailingPunctuation(url[url.length - 1])) {
        suffix = url[url.length - 1] + suffix;
        url = url.substring(0, url.length - 1);
      }
      if (url.isEmpty) return match.group(2)!;
      return '[$url]($url)$suffix';
    });
  }

  static bool _isTrailingPunctuation(String char) =>
      const ['.', ',', ';', ':', '!', '?'].contains(char);
}
