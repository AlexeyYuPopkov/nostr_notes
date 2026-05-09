import 'package:flutter/material.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:common/domain/repo/key_tool_repository.dart';

extension InvalidNsecErrorMessage on InvalidNsecError {
  String getMessage(BuildContext context) {
    return context.l10n.errorInvalidNsecFormat;
  }
}
