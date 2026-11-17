import 'package:common/l10n/common_localizations.dart';
import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart' show GlobalMaterialLocalizations;

typedef CommonL10n = CommonLocalizations;

/// Use instead of the generated `localizationsDelegates`: gen-l10n
/// (Flutter 3.50) still emits the `flutter_localizations` Material/Cupertino
/// delegates, which `material_ui`/`cupertino_ui` widgets don't look up.
const List<LocalizationsDelegate<Object?>> platformLocalizationsDelegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];

extension CommonLocalizationHelper on BuildContext {
  CommonL10n get commonL10n => CommonL10n.of(this)!;
}
