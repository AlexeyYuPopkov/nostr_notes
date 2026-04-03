import 'package:common/l10n/common_localizations.dart';
import 'package:flutter/widgets.dart';

typedef CommonL10n = CommonLocalizations;

extension CommonLocalizationHelper on BuildContext {
  CommonL10n get commonL10n => CommonL10n.of(this)!;
}
