import 'package:flutter/material.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:flutter/services.dart';

mixin LinkTapHandler on StatelessWidget {
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
          await _copyToClipboard(context, url);
        }
      }
    } catch (e) {
      if (context.mounted) {
        await _copyToClipboard(context, url);
      }
    }
  }

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            children: [
              Text('${context.l10n.commonCopied}:'),
              Text(_sanitarizeUrl(text)),
            ],
          ),
        ),
      );
    }
  }

  String _sanitarizeUrl(String url) {
    String result = url.trim();

    if (result.startsWith('mailto:')) {
      result = result.substring(7);
    } else if (result.startsWith('tel:')) {
      result = result.substring(4);
    }
    return result;
  }
}
