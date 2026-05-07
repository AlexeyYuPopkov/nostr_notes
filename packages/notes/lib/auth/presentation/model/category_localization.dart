import 'package:flutter/material.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/l10n/localization.dart';

extension CategoryLocalization on CategoryType {
  String getLocalizedName(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case .finance:
        return l10n.classificationClassFinance;
      case .journal:
        return l10n.classificationClassJournal;
      case .personal:
        return l10n.classificationClassPersonal;
      case .security:
        return l10n.classificationClassSecurity;
      case .travel:
        return l10n.classificationClassTravel;
      case .work:
        return l10n.classificationClassWork;
      case .bookmarks:
        return l10n.classificationClassBookmarks;
      case .other:
        return l10n.classificationClassOther;
    }
  }
}
