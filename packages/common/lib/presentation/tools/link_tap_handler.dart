import 'package:common/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:flutter/services.dart';

mixin LinkTapHandler on StatelessWidget {
  static String sanitizeUrl(String url) {
    String result = url.trim();
    if (result.startsWith('mailto:')) {
      result = result.substring(7);
    } else if (result.startsWith('tel:')) {
      result = result.substring(4);
    }
    return result;
  }

  static Future<void> copyUrlToClipboard(
    BuildContext context,
    String url,
  ) async {
    final text = sanitizeUrl(url);
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            children: [Text('${context.commonL10n.commonCopied}:'), Text(text)],
          ),
        ),
      );
    }
  }

  Future<void> launchUrl(BuildContext context, {required String? url}) async {
    if (url == null || url.isEmpty) {
      return;
    }
    final uri = Uri.tryParse(url);
    try {
      if (uri != null && await launcher.canLaunchUrl(uri)) {
        await launcher.launchUrl(uri);
      } else {
        if (context.mounted) {
          await copyUrlToClipboard(context, url);
        }
      }
    } catch (e) {
      if (context.mounted) {
        await copyUrlToClipboard(context, url);
      }
    }
  }
}
