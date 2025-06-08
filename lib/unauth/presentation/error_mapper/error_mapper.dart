import 'package:flutter/material.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/common/domain/repository/key_tool_repository.dart';

extension InvalidNsecErrorMessage on InvalidNsecError {
  String getMessage(BuildContext context) {
    return context.l10n.errorInvalidNsec;
  }
}
