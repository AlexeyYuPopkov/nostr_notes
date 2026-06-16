import 'package:flutter/widgets.dart';
import 'package:nostr/key_tool/key_tool.dart';
import 'package:nostr_notes/l10n/localization.dart';

mixin NsecValidator {
  String? validateNsec(BuildContext context, String? value) {
    final l10n = context.l10n;
    if (value == null || value.trim().isEmpty) {
      return l10n.onboardingNsecPageValidationEmpty;
    }
    final trimmed = value.trim();
    if (trimmed.startsWith('npub')) {
      return l10n.onboardingNsecPageValidationNpub;
    }
    final privateKey = KeyTool.tryDecodeNsecKeyToPrivateKey(trimmed);
    if (privateKey == null) {
      return l10n.onboardingNsecPageValidationInvalid;
    }
    return null;
  }
}
