import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'common_localizations_bg.dart';
import 'common_localizations_en.dart';
import 'common_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of CommonLocalizations
/// returned by `CommonLocalizations.of(context)`.
///
/// Applications need to include `CommonLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/common_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: CommonLocalizations.localizationsDelegates,
///   supportedLocales: CommonLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the CommonLocalizations.supportedLocales
/// property.
abstract class CommonLocalizations {
  CommonLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static CommonLocalizations? of(BuildContext context) {
    return Localizations.of<CommonLocalizations>(context, CommonLocalizations);
  }

  static const LocalizationsDelegate<CommonLocalizations> delegate =
      _CommonLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bg'),
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @commonButtonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonButtonBack;

  /// No description provided for @commonButtonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonButtonOk;

  /// No description provided for @commonButtonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonButtonCancel;

  /// No description provided for @commonButtonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonButtonContinue;

  /// No description provided for @commonButtonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonButtonNext;

  /// No description provided for @commonButtonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonButtonSave;

  /// No description provided for @commonButtonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonButtonDone;

  /// No description provided for @commonButtonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonButtonEdit;

  /// No description provided for @commonHintSearch.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get commonHintSearch;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonAttention.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get commonAttention;

  /// No description provided for @commonUndefinedError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonUndefinedError;

  /// No description provided for @commonNoDataPlaceholderText.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get commonNoDataPlaceholderText;

  /// No description provided for @commonCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get commonCopied;

  /// No description provided for @commonInfo.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get commonInfo;

  /// No description provided for @commonWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get commonWarning;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error'**
  String get authError;

  /// No description provided for @themeScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeScreenTitle;

  /// No description provided for @themeScreenSectionTitleColorTheme.
  ///
  /// In en, this message translates to:
  /// **'Color theme'**
  String get themeScreenSectionTitleColorTheme;

  /// No description provided for @themeScreenLabelSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeScreenLabelSystem;

  /// No description provided for @themeScreenLabelLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeScreenLabelLight;

  /// No description provided for @themeScreenLabelDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeScreenLabelDark;

  /// No description provided for @themeScreenLabelBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get themeScreenLabelBackground;

  /// No description provided for @themeScreenLabelCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get themeScreenLabelCards;

  /// No description provided for @relaysPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Relays'**
  String get relaysPageTitle;

  /// No description provided for @relaysPageDescription.
  ///
  /// In en, this message translates to:
  /// **'Relays are servers that store and deliver your encrypted notes. Select at least one relay to continue'**
  String get relaysPageDescription;

  /// No description provided for @relaysPageAddCustomLabel.
  ///
  /// In en, this message translates to:
  /// **'Optionally, add your own relay by its address'**
  String get relaysPageAddCustomLabel;

  /// No description provided for @relaysPageAddCustomHint.
  ///
  /// In en, this message translates to:
  /// **'wss://...'**
  String get relaysPageAddCustomHint;

  /// No description provided for @relaysPageAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get relaysPageAddButton;

  /// No description provided for @relaysPageCheckButton.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get relaysPageCheckButton;

  /// No description provided for @relaysPageErrorSelectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Select at least one relay'**
  String get relaysPageErrorSelectAtLeastOne;

  /// No description provided for @relaysPageErrorInvalidRelayUrlEmpty.
  ///
  /// In en, this message translates to:
  /// **'URL cannot be empty'**
  String get relaysPageErrorInvalidRelayUrlEmpty;

  /// No description provided for @relaysPageErrorInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'URL must start with wss:// or ws://'**
  String get relaysPageErrorInvalidUrl;

  /// No description provided for @relaysPageErrorInvalidRelayAddressFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid relay address format'**
  String get relaysPageErrorInvalidRelayAddressFormat;

  /// No description provided for @relaysPageErrorFailedToConnectToRelay.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to relay {url}'**
  String relaysPageErrorFailedToConnectToRelay(String url);

  /// No description provided for @rawEventScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Raw event'**
  String get rawEventScreenTitle;

  /// No description provided for @rawEventScreenSectionTitleRelaysCount.
  ///
  /// In en, this message translates to:
  /// **'Relays ({count})'**
  String rawEventScreenSectionTitleRelaysCount(String count);

  /// No description provided for @rawEventScreenSectionTitleJson.
  ///
  /// In en, this message translates to:
  /// **'JSON'**
  String get rawEventScreenSectionTitleJson;

  /// No description provided for @commonLinkCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get commonLinkCopyLink;

  /// No description provided for @commonLinkOpenInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get commonLinkOpenInBrowser;

  /// No description provided for @commonLinkOpenInNewTab.
  ///
  /// In en, this message translates to:
  /// **'Open in new tab'**
  String get commonLinkOpenInNewTab;

  /// No description provided for @commonLinkOpenInExternalBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in external browser'**
  String get commonLinkOpenInExternalBrowser;
}

class _CommonLocalizationsDelegate
    extends LocalizationsDelegate<CommonLocalizations> {
  const _CommonLocalizationsDelegate();

  @override
  Future<CommonLocalizations> load(Locale locale) {
    return SynchronousFuture<CommonLocalizations>(
      lookupCommonLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bg', 'en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_CommonLocalizationsDelegate old) => false;
}

CommonLocalizations lookupCommonLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bg':
      return CommonLocalizationsBg();
    case 'en':
      return CommonLocalizationsEn();
    case 'ru':
      return CommonLocalizationsRu();
  }

  throw FlutterError(
    'CommonLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
