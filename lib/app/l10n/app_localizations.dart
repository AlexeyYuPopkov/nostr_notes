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

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

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

  /// No description provided for @onboardingPinPageInfoPin.
  ///
  /// In en, this message translates to:
  /// **'The PIN is an additional layer of protection against nsec compromise. It is stored only in memory and is never persisted. If the PIN is lost, your existing notes cannot be decrypted. If you create or edit a note with an incorrect PIN, that note will be encrypted with the wrong PIN.'**
  String get onboardingPinPageInfoPin;

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
  /// **'Do you really want to log out and clear all data? This action cannot be undone.\nMake sure you have saved your nsec and PIN — if you forget either, your data will be lost permanently.'**
  String get settingsScreenLogoutConfirmationMessage;

  /// No description provided for @settingsItemPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsItemPreferences;

  /// No description provided for @settingsItemHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsItemHelp;

  /// No description provided for @preferencesScreenItemRelays.
  ///
  /// In en, this message translates to:
  /// **'Connected Relays'**
  String get preferencesScreenItemRelays;

  /// No description provided for @preferencesScreenItemMobilePinKeyboardType.
  ///
  /// In en, this message translates to:
  /// **'PIN Keyboard Type'**
  String get preferencesScreenItemMobilePinKeyboardType;

  /// No description provided for @pinKeyboardTypeScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'PIN Keyboard Type'**
  String get pinKeyboardTypeScreenTitle;

  /// No description provided for @pinKeyboardTypeScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the keyboard type shown when entering your PIN'**
  String get pinKeyboardTypeScreenDescription;

  /// No description provided for @pinKeyboardTypeText.
  ///
  /// In en, this message translates to:
  /// **'Default (Text)'**
  String get pinKeyboardTypeText;

  /// No description provided for @pinKeyboardTypeNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get pinKeyboardTypeNumber;

  /// No description provided for @pinKeyboardTypePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get pinKeyboardTypePhone;

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

  /// No description provided for @notesListPendingSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync pending'**
  String get notesListPendingSyncTitle;

  /// No description provided for @notesListPendingSyncDescription.
  ///
  /// In en, this message translates to:
  /// **'This note hasn\'t been synced with the network yet'**
  String get notesListPendingSyncDescription;

  /// No description provided for @credentialsDataScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Credentials Data'**
  String get credentialsDataScreenTitle;

  /// No description provided for @credentialsDataScreenLabelNsec.
  ///
  /// In en, this message translates to:
  /// **'Nsec'**
  String get credentialsDataScreenLabelNsec;

  /// No description provided for @credentialsDataScreenLabelPrivateKey.
  ///
  /// In en, this message translates to:
  /// **'Private Key'**
  String get credentialsDataScreenLabelPrivateKey;

  /// No description provided for @credentialsDataScreenLabelPubKey.
  ///
  /// In en, this message translates to:
  /// **'Public Key'**
  String get credentialsDataScreenLabelPubKey;

  /// No description provided for @credentialsDataScreenLabelPin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get credentialsDataScreenLabelPin;

  /// No description provided for @credentialsDataScreenWarningNsec.
  ///
  /// In en, this message translates to:
  /// **'Your nsec (private key) is stored only on this device in secure storage (Keychain on iOS, Keystore on Android). It is never sent to any server. Losing your nsec means losing access to all your data permanently.'**
  String get credentialsDataScreenWarningNsec;

  /// No description provided for @credentialsDataScreenWarningPin.
  ///
  /// In en, this message translates to:
  /// **'The PIN is an additional layer of protection against nsec compromise. It is stored only in memory and is never persisted. If the PIN is lost, your existing notes cannot be decrypted. If you create or edit a note with an incorrect PIN, that note will be encrypted with the wrong PIN.'**
  String get credentialsDataScreenWarningPin;

  /// No description provided for @credentialsDataScreenWarningPrivateKey.
  ///
  /// In en, this message translates to:
  /// **'The private key is a hex representation of your nsec. Both formats grant full access to your account.'**
  String get credentialsDataScreenWarningPrivateKey;

  /// No description provided for @credentialsDataScreenInfoPubKey.
  ///
  /// In en, this message translates to:
  /// **'Your public key uniquely identifies your account on the Nostr network. It is safe to share — anyone can use it to find and verify your posts.'**
  String get credentialsDataScreenInfoPubKey;

  /// No description provided for @helpScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpScreenTitle;

  /// No description provided for @helpScreenContent.
  ///
  /// In en, this message translates to:
  /// **'# NotesVault\n\nNotesVault is a private, encrypted note-taking app built on the **Nostr** protocol. Your notes are encrypted on your device and synced through decentralized relays — no company owns your data.\n\n---\n\n## What is Nostr?\n\nNostr (Notes and Other Stuff Transmitted by Relays) is an open, decentralized protocol. Instead of a central server, it uses a network of **relays** — independent servers that store and forward your data. Your identity is a cryptographic key pair, not an email or phone number.\n\n---\n\n## Key Concepts\n\n### 🔑 Nsec (Private Key)\n\nYour **nsec** is your master key. It starts with `nsec1...` and is the bech32 encoding of your private key (hex). It is used to:\n\n- **Sign** your notes so relays can verify they come from you\n- **Encrypt** and **decrypt** your note content\n- **Prove ownership** of your account\n\n> ⚠️ **Never share your nsec with anyone.** Anyone who has it gains full control of your account. There is no \"forgot password\" — if you lose your nsec, your data is gone forever.\n\nYour nsec is stored only on this device in secure storage (Keychain on iOS, Keystore on Android). It is never sent to any server.\n\n### 🌐 Public Key (npub)\n\nYour **public key** (displayed as `npub1...`) is your public identity on the Nostr network. It is derived from your nsec and is safe to share. Anyone can use it to look up your profile across Nostr apps.\n\n### 🔒 PIN / Password\n\nThe PIN provides an **extra layer of encryption** on top of your nsec. Even if someone obtains your private key, they still cannot read your notes without the PIN.\n\nImportant details:\n\n- The PIN is **never saved to disk** — it lives only in memory while the app is open\n- If you **forget your PIN**, existing notes **cannot be decrypted**\n- If you enter a **wrong PIN**, new or edited notes will be encrypted with that incorrect PIN, making them unreadable with the correct one\n\n### 📡 Relays\n\nRelays are servers that store and deliver your encrypted notes. You can choose which relays to use in **Settings → Preferences → Connected Relays**. Using multiple relays increases redundancy — if one goes offline, your data is still available on others.\n\n---\n\n## How It Works\n\n1. **Create** a note in the editor\n2. The note is **encrypted** on your device using NIP-44 encryption with your nsec and PIN\n3. The encrypted note is **signed** and **published** to your selected relays\n4. When you open the app, notes are **fetched** from relays and **decrypted** locally\n\nNo one — not the relay operators, not us — can read your notes. Only you, with your nsec and PIN, can decrypt them.\n\n---\n\n## Tips\n\n- **Back up your nsec** in a secure place (e.g., a password manager). Without it, your account cannot be recovered.\n- **Remember your PIN.** It is not stored anywhere and cannot be reset.\n- **Use multiple relays** for better availability and redundancy.\n- Your nsec works across all Nostr apps — you can use the same identity everywhere.'**
  String get helpScreenContent;

  /// No description provided for @notesListScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesListScreenTitle;

  /// No description provided for @homeScreenEmptyStatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select a note or create a new one'**
  String get homeScreenEmptyStatePlaceholder;

  /// No description provided for @notesListSectionToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notesListSectionToday;

  /// No description provided for @notesListSectionPrevious7Days.
  ///
  /// In en, this message translates to:
  /// **'Previous 7 Days'**
  String get notesListSectionPrevious7Days;

  /// No description provided for @notesListSectionPrevious30Days.
  ///
  /// In en, this message translates to:
  /// **'Previous 30 Days'**
  String get notesListSectionPrevious30Days;

  /// No description provided for @notesListSectionOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get notesListSectionOther;
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
