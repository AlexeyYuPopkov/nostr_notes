import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

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
  /// **'No data'**
  String get commonNoDataPlaceholderText;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error'**
  String get authError;

  /// No description provided for @notUnlocked.
  ///
  /// In en, this message translates to:
  /// **'The app is not unlocked'**
  String get notUnlocked;

  /// No description provided for @onboardingWelcomePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nNotesVault'**
  String get onboardingWelcomePageTitle;

  /// No description provided for @onboardingWelcomePageDescription.
  ///
  /// In en, this message translates to:
  /// **'Securely store short notes and passwords\n– encrypted, decentralized, just for you'**
  String get onboardingWelcomePageDescription;

  /// No description provided for @onboardingWelcomePageOptionMD1.
  ///
  /// In en, this message translates to:
  /// **'✏️ **Create** short notes and passwords'**
  String get onboardingWelcomePageOptionMD1;

  /// No description provided for @onboardingWelcomePageOptionMD2.
  ///
  /// In en, this message translates to:
  /// **'🔐 **Encrypted** on your device'**
  String get onboardingWelcomePageOptionMD2;

  /// No description provided for @onboardingWelcomePageOptionMD3.
  ///
  /// In en, this message translates to:
  /// **'🌐 **Stored** via Nostr'**
  String get onboardingWelcomePageOptionMD3;

  /// No description provided for @onboardingWelcomePageOptionMD4.
  ///
  /// In en, this message translates to:
  /// **'🧷 **Access** with your **nsec** and **PIN**'**
  String get onboardingWelcomePageOptionMD4;

  /// No description provided for @onboardingWelcomeButtonNext.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingWelcomeButtonNext;

  /// No description provided for @onboardingNsecPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your Nostr nsec'**
  String get onboardingNsecPageTitle;

  /// No description provided for @onboardingNsecPageDescription.
  ///
  /// In en, this message translates to:
  /// **'Your private key is used to encrypt and sign notes. It is only yours and never leaves the device'**
  String get onboardingNsecPageDescription;

  /// No description provided for @onboardingNsecPageTextFieldHint.
  ///
  /// In en, this message translates to:
  /// **'nsec1...'**
  String get onboardingNsecPageTextFieldHint;

  /// No description provided for @onboardingNsecPageLabelHint.
  ///
  /// In en, this message translates to:
  /// **'You can import from another app or paste it manually'**
  String get onboardingNsecPageLabelHint;

  /// No description provided for @onboardingPinPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN or password'**
  String get onboardingPinPageTitle;

  /// No description provided for @onboardingPinPageDescription.
  ///
  /// In en, this message translates to:
  /// **'This is used for an additional layer of encryption – even if someone obtains your nsec, your notes will remain protected'**
  String get onboardingPinPageDescription;

  /// No description provided for @onboardingPinPageTextFieldHint.
  ///
  /// In en, this message translates to:
  /// **'PIN or password'**
  String get onboardingPinPageTextFieldHint;

  /// No description provided for @onboardingPinPageLabelCheckboxUsePin.
  ///
  /// In en, this message translates to:
  /// **'Use pin to unlock app'**
  String get onboardingPinPageLabelCheckboxUsePin;

  /// No description provided for @errorEmptyNsec.
  ///
  /// In en, this message translates to:
  /// **'NSEC key cannot be empty'**
  String get errorEmptyNsec;

  /// No description provided for @errorInvalidNsecFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid NSEC key format'**
  String get errorInvalidNsecFormat;

  /// No description provided for @errorInvalidPrivateKey.
  ///
  /// In en, this message translates to:
  /// **'Invalid private key'**
  String get errorInvalidPrivateKey;

  /// No description provided for @errorEmptyPubkey.
  ///
  /// In en, this message translates to:
  /// **'Public key cannot be empty'**
  String get errorEmptyPubkey;

  /// No description provided for @errorEmptyPin.
  ///
  /// In en, this message translates to:
  /// **'PIN or password cannot be empty'**
  String get errorEmptyPin;

  /// No description provided for @errorInvalidPinFormatMinCount.
  ///
  /// In en, this message translates to:
  /// **'PIN or password must be at least {minCount} characters long'**
  String errorInvalidPinFormatMinCount(String minCount);

  /// No description provided for @settingsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// No description provided for @settingsScreenExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get settingsScreenExit;

  /// No description provided for @settingsScreenLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout and clear data'**
  String get settingsScreenLogout;

  /// No description provided for @settingsScreenLogoutConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to log out and clear all data? This action cannot be undone'**
  String get settingsScreenLogoutConfirmationMessage;

  /// No description provided for @noteScreenErrorNoteContentCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Note content cannot be empty'**
  String get noteScreenErrorNoteContentCannotBeEmpty;

  /// No description provided for @errorPublishOperationTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Publish operation timed out'**
  String get errorPublishOperationTimedOut;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
