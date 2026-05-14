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
  String get commonHintSearch => 'Search...';

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
  String get themeScreenLabelBackground => 'Background';

  @override
  String get themeScreenLabelCards => 'Cards';

  @override
  String get relaysPageTitle => 'Select Relays';

  @override
  String get relaysPageDescription =>
      'Relays are servers that store and deliver your encrypted notes. Select at least one relay to continue';

  @override
  String get relaysPageAddCustomHint => 'wss://...';

  @override
  String get relaysPageAddButton => 'Add';

  @override
  String get relaysPageCheckButton => 'Check';

  @override
  String get relaysPageErrorSelectAtLeastOne => 'Select at least one relay';

  @override
  String get relaysPageErrorInvalidRelayUrlEmpty => 'URL cannot be empty';

  @override
  String get relaysPageErrorInvalidUrl => 'URL must start with wss:// or ws://';

  @override
  String get relaysPageErrorInvalidRelayAddressFormat =>
      'Invalid relay address format';

  @override
  String relaysPageErrorFailedToConnectToRelay(String url) {
    return 'Failed to connect to relay $url';
  }

  @override
  String get rawEventScreenTitle => 'Raw event';

  @override
  String rawEventScreenSectionTitleRelaysCount(String count) {
    return 'Relays ($count)';
  }

  @override
  String get rawEventScreenSectionTitleJson => 'JSON';
}
