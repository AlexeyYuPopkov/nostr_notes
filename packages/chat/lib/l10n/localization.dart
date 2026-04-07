import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

typedef Localization = AppLocalizations;

extension LocalizationHelper on BuildContext {
  Localization get l10n => AppLocalizations.of(this)!;
}
