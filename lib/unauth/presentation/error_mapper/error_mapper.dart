import 'package:flutter/material.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/unauth/domain/validators/nsec_validator.dart';

extension InvalidNsecErrorMessage on InvalidNsecError {
  String getMessage(BuildContext context) {
    return context.l10n.errorInvalidNsec;
  }
}
