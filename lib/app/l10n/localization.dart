import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef Localization = AppLocalizations;

extension LocalizationHelper on BuildContext {
  Localization get l10n => AppLocalizations.of(this)!;
}
