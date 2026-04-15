// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'common_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class CommonLocalizationsEn extends CommonLocalizations {
  CommonLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonButtonBack => 'Back';

  @override
  String get commonButtonOk => 'OK';

  @override
  String get commonButtonCancel => 'Cancel';

  @override
  String get commonButtonContinue => 'Continue';

  @override
  String get commonButtonNext => 'Next';

  @override
  String get commonButtonSave => 'Save';

  @override
  String get commonButtonDone => 'Done';

  @override
  String get commonButtonEdit => 'Edit';

  @override
  String get commonClose => 'Close';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonError => 'Error';

  @override
  String get commonAttention => 'Attention';

  @override
  String get commonUndefinedError => 'Something went wrong';

  @override
  String get commonNoDataPlaceholderText => 'No data found';

  @override
  String get commonCopied => 'Copied';

  @override
  String get commonInfo => 'Information';

  @override
  String get authError => 'Authentication error';

  @override
  String get themeScreenTitle => 'Theme';

  @override
  String get themeScreenLabelSystem => 'System';

  @override
  String get themeScreenLabelLight => 'Light';

  @override
  String get themeScreenLabelDark => 'Dark';

  @override
  String get rawEventScreenTitle => 'Raw event';

  @override
  String rawEventScreenSectionTitleRelaysCount(String count) {
    return 'Relays ($count)';
  }

  @override
  String get rawEventScreenSectionTitleJson => 'JSON';
}
