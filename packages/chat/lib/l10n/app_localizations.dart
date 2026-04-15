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

  /// No description provided for @appDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Encrypted Chat (Nostr)'**
  String get appDisplayName;

  /// No description provided for @notUnlocked.
  ///
  /// In en, this message translates to:
  /// **'The app is not unlocked'**
  String get notUnlocked;

  /// No description provided for @notePreviewCannotDecryptTitle.
  ///
  /// In en, this message translates to:
  /// **'This message could not be decrypted'**
  String get notePreviewCannotDecryptTitle;

  /// No description provided for @notePreviewCannotDecryptDescription.
  ///
  /// In en, this message translates to:
  /// **'Messages are encrypted with NIP-44. Decryption may fail due to a key mismatch, data corruption, or if the message was sent from a different identity.'**
  String get notePreviewCannotDecryptDescription;

  /// No description provided for @onboardingWelcomePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nEncrypted Chat (Nostr)'**
  String get onboardingWelcomePageTitle;

  /// No description provided for @onboardingWelcomePageDescription.
  ///
  /// In en, this message translates to:
  /// **'Send private messages – encrypted, decentralized, without intermediaries'**
  String get onboardingWelcomePageDescription;

  /// No description provided for @onboardingWelcomePageOptionMD1.
  ///
  /// In en, this message translates to:
  /// **'💬 **Send** encrypted direct messages'**
  String get onboardingWelcomePageOptionMD1;

  /// No description provided for @onboardingWelcomePageOptionMD2.
  ///
  /// In en, this message translates to:
  /// **'🔐 **Encrypted** end-to-end with **NIP-44**'**
  String get onboardingWelcomePageOptionMD2;

  /// No description provided for @onboardingWelcomePageOptionMD3.
  ///
  /// In en, this message translates to:
  /// **'🌐 **Delivered** via Nostr relays'**
  String get onboardingWelcomePageOptionMD3;

  /// No description provided for @onboardingWelcomePageOptionMD4.
  ///
  /// In en, this message translates to:
  /// **'🔑 **Access** with your **nsec** key'**
  String get onboardingWelcomePageOptionMD4;

  /// No description provided for @onboardingWelcomeButtonNext.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingWelcomeButtonNext;

  /// No description provided for @onboardingSignUpPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up with Nostr'**
  String get onboardingSignUpPageTitle;

  /// No description provided for @onboardingSignUpPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What is Nostr?'**
  String get onboardingSignUpPageSubtitle;

  /// No description provided for @onboardingSignUpPageDescription.
  ///
  /// In en, this message translates to:
  /// **'Nostr is a decentralized network designed for secure and censorship-resistant communication. Unlike traditional platforms, Nostr doesn\'t rely on centralized servers—your identity and data belong to you.'**
  String get onboardingSignUpPageDescription;

  /// No description provided for @onboardingSignUpPageWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why Sign Up with Nostr?'**
  String get onboardingSignUpPageWhyTitle;

  /// No description provided for @onboardingSignUpPageOptionMD1.
  ///
  /// In en, this message translates to:
  /// **'✅ **Instant Access** - One click generates your private key. No email or password required.'**
  String get onboardingSignUpPageOptionMD1;

  /// No description provided for @onboardingSignUpPageOptionMD2.
  ///
  /// In en, this message translates to:
  /// **'🔐 **You own your identity** - Your key is your identity. No company controls your account.'**
  String get onboardingSignUpPageOptionMD2;

  /// No description provided for @onboardingSignUpPageOptionMD3.
  ///
  /// In en, this message translates to:
  /// **'🌍 **Works Everywhere** - Use the same key across all Nostr-powered apps'**
  String get onboardingSignUpPageOptionMD3;

  /// No description provided for @onboardingSignUpButtonGenerateKey.
  ///
  /// In en, this message translates to:
  /// **'Generate a Nostr Key'**
  String get onboardingSignUpButtonGenerateKey;

  /// No description provided for @onboardingSignUpAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get onboardingSignUpAlreadyHaveAccount;

  /// No description provided for @onboardingSignUpButtonLogin.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get onboardingSignUpButtonLogin;

  /// No description provided for @onboardingShowNsecPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Nostr Private Key (Nsec Key)'**
  String get onboardingShowNsecPageTitle;

  /// No description provided for @onboardingShowNsecPageDescription.
  ///
  /// In en, this message translates to:
  /// **'Save this key securely. Your Nsec key gives you complete control and ownership of your data.'**
  String get onboardingShowNsecPageDescription;

  /// No description provided for @onboardingShowNsecPageOptionMD1.
  ///
  /// In en, this message translates to:
  /// **'🔑 **Required** – This key is your account password and is required to log in.'**
  String get onboardingShowNsecPageOptionMD1;

  /// No description provided for @onboardingShowNsecPageOptionMD2.
  ///
  /// In en, this message translates to:
  /// **'📌 **Permanent** – Keep a secure backup. We cannot change or recover it.'**
  String get onboardingShowNsecPageOptionMD2;

  /// No description provided for @onboardingShowNsecPageOptionMD3.
  ///
  /// In en, this message translates to:
  /// **'🚫 **Private** – Anyone with this key can access your account. Never share it.'**
  String get onboardingShowNsecPageOptionMD3;

  /// No description provided for @onboardingShowNsecPageButtonCopyKey.
  ///
  /// In en, this message translates to:
  /// **'Copy Key'**
  String get onboardingShowNsecPageButtonCopyKey;

  /// No description provided for @onboardingShowNsecPageKeyCopied.
  ///
  /// In en, this message translates to:
  /// **'Key copied to clipboard'**
  String get onboardingShowNsecPageKeyCopied;

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

  /// No description provided for @onboardingNsecPageDontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get onboardingNsecPageDontHaveAccount;

  /// No description provided for @onboardingNsecPageButtonSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get onboardingNsecPageButtonSignUp;
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
    'that was used.',
  );
}
