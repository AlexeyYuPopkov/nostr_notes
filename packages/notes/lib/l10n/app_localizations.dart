import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bg.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bg'),
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Private Notes (Nostr)'**
  String get appDisplayName;

  /// No description provided for @notUnlocked.
  ///
  /// In en, this message translates to:
  /// **'The app is not unlocked'**
  String get notUnlocked;

  /// No description provided for @notePreviewCannotDecryptTitle.
  ///
  /// In en, this message translates to:
  /// **'This note could not be decrypted'**
  String get notePreviewCannotDecryptTitle;

  /// No description provided for @notePreviewCannotDecryptDescription.
  ///
  /// In en, this message translates to:
  /// **'PIN/password is optional: notes without PIN remain fully NIP-44 compatible. This can happen due to a wrong PIN, data mismatch between devices, or corrupted/incomplete note data.'**
  String get notePreviewCannotDecryptDescription;

  /// No description provided for @onboardingWelcomePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nPrivate Notes (Nostr)'**
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

  /// No description provided for @apkDistributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Download APK'**
  String get apkDistributionTitle;

  /// No description provided for @apkDistributionDescription.
  ///
  /// In en, this message translates to:
  /// **'You can download the installation file directly. It is recommended to verify the SHA-256 checksum after downloading.'**
  String get apkDistributionDescription;

  /// No description provided for @apkDistributionDownloadButton.
  ///
  /// In en, this message translates to:
  /// **'Download .apk'**
  String get apkDistributionDownloadButton;

  /// No description provided for @apkDistributionViewChecksum.
  ///
  /// In en, this message translates to:
  /// **'View Checksum (SHA-256)'**
  String get apkDistributionViewChecksum;

  /// No description provided for @appStoreBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Available on the App Store'**
  String get appStoreBannerTitle;

  /// No description provided for @appStoreBannerButton.
  ///
  /// In en, this message translates to:
  /// **'Open in AppStore'**
  String get appStoreBannerButton;

  /// No description provided for @apkBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Android APK'**
  String get apkBannerTitle;

  /// No description provided for @apkBannerButton.
  ///
  /// In en, this message translates to:
  /// **'Download APK'**
  String get apkBannerButton;

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

  /// No description provided for @settingsScreenSectionSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenSectionSettingsTitle;

  /// No description provided for @settingsScreenSectionSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get settingsScreenSectionSessionTitle;

  /// No description provided for @settingsScreenSectionAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsScreenSectionAccountTitle;

  /// No description provided for @settingsScreenExit.
  ///
  /// In en, this message translates to:
  /// **'Lock App'**
  String get settingsScreenExit;

  /// No description provided for @settingsScreenLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsScreenLogout;

  /// No description provided for @settingsScreenLogoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Remove your private key from this device'**
  String get settingsScreenLogoutDescription;

  /// No description provided for @settingsScreenLogoutConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to log out and clear all data? This action cannot be undone.\nMake sure you have saved your nsec and PIN — if you forget either, your data will be lost permanently.'**
  String get settingsScreenLogoutConfirmationMessage;

  /// No description provided for @settingsScreenDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsScreenDeleteAccount;

  /// No description provided for @settingsScreenDeleteDescription.
  ///
  /// In en, this message translates to:
  /// **'Delete notes from relays and clear local data'**
  String get settingsScreenDeleteDescription;

  /// No description provided for @settingsScreenDeleteAccountConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'This action will permanently delete your account from this device and initiate the removal of your data from the **Nostr** network.\n\n### What will happen:\n- **Locally:** Your **private key** and all notes will be irreversibly erased from this device.\n- **On the Nostr network:** A request to delete all your notes will be sent to your relays. Most relays will honor this request.\n\n### Important to know:\nYour notes are end-to-end encrypted. Even if copies remain on some relays, they cannot be read without your private key (which was stored only in the Keychain), which is now permanently deleted.'**
  String get settingsScreenDeleteAccountConfirmationMessage;

  /// No description provided for @settingsScreenDeleteAccountStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Collecting notes to delete...'**
  String get settingsScreenDeleteAccountStatusPreparing;

  /// No description provided for @settingsScreenDeleteAccountStatusKind5Publishing.
  ///
  /// In en, this message translates to:
  /// **'Publishing deletion requests...'**
  String get settingsScreenDeleteAccountStatusKind5Publishing;

  /// No description provided for @settingsScreenDeleteAccountStatusClearLocalStorages.
  ///
  /// In en, this message translates to:
  /// **'Clearing local data...'**
  String get settingsScreenDeleteAccountStatusClearLocalStorages;

  /// No description provided for @settingsScreenDeleteAccountStatusLogout.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get settingsScreenDeleteAccountStatusLogout;

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

  /// No description provided for @settingsItemContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get settingsItemContacts;

  /// No description provided for @settingsItemBuyMeACoffee.
  ///
  /// In en, this message translates to:
  /// **'Buy me a coffee ☕'**
  String get settingsItemBuyMeACoffee;

  /// No description provided for @settingsItemDonateBTC.
  ///
  /// In en, this message translates to:
  /// **'Donate via Lightning ⚡'**
  String get settingsItemDonateBTC;

  /// No description provided for @settingsItemContactsLabelContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get settingsItemContactsLabelContacts;

  /// No description provided for @settingsItemContactsContactsMd.
  ///
  /// In en, this message translates to:
  /// **'- 📧 Email: [alexey.yu.popkov@gmail.com](mailto:alexey.yu.popkov@gmail.com)\n- 📱 Telegram: [@alexey_yu_popkov](https://t.me/alexey_yu_popkov)\n- 💼 LinkedIn: [https://www.linkedin.com/in/alekseii-popkov-57007282](https://www.linkedin.com/in/alekseii-popkov-57007282)'**
  String get settingsItemContactsContactsMd;

  /// No description provided for @settingsItemContactsLabelFAQ.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get settingsItemContactsLabelFAQ;

  /// No description provided for @settingsItemContactsMdFaq.
  ///
  /// In en, this message translates to:
  /// **'\n\n- Forgot PIN? Notes cannot be recovered — PIN is never stored.\n- Lost nsec? Account cannot be restored without private key.'**
  String get settingsItemContactsMdFaq;

  /// No description provided for @preferencesScreenItemRelays.
  ///
  /// In en, this message translates to:
  /// **'Connected Relays'**
  String get preferencesScreenItemRelays;

  /// No description provided for @preferencesScreenItemLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get preferencesScreenItemLanguage;

  /// No description provided for @preferencesScreenLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get preferencesScreenLanguageSystem;

  /// No description provided for @preferencesScreenLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get preferencesScreenLanguageEnglish;

  /// No description provided for @preferencesScreenLanguageRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get preferencesScreenLanguageRussian;

  /// No description provided for @preferencesScreenLanguageBulgarian.
  ///
  /// In en, this message translates to:
  /// **'Български'**
  String get preferencesScreenLanguageBulgarian;

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

  /// No description provided for @exportImportScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Export & Import'**
  String get exportImportScreenTitle;

  /// No description provided for @exportImportSectionExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportImportSectionExportTitle;

  /// No description provided for @exportImportSectionImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get exportImportSectionImportTitle;

  /// No description provided for @exportImportItemExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export All Notes'**
  String get exportImportItemExportTitle;

  /// No description provided for @exportImportItemExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export all your notes to a password-protected ZIP archive. Notes are encrypted using AES-256-CBC. If no password is provided, they will be archived without encryption.'**
  String get exportImportItemExportSubtitle;

  /// No description provided for @exportImportItemImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import All Notes'**
  String get exportImportItemImportTitle;

  /// No description provided for @exportImportItemImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore notes from a previously exported archive.'**
  String get exportImportItemImportSubtitle;

  /// No description provided for @exportImportSectionDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get exportImportSectionDataTitle;

  /// No description provided for @exportImportPasswordDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Export Password'**
  String get exportImportPasswordDialogTitle;

  /// No description provided for @exportImportPasswordDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to export without encryption'**
  String get exportImportPasswordDialogHint;

  /// No description provided for @exportImportPasswordDialogTextFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Password (optional)'**
  String get exportImportPasswordDialogTextFieldHint;

  /// No description provided for @exportImportExportEmptyError.
  ///
  /// In en, this message translates to:
  /// **'No notes to export'**
  String get exportImportExportEmptyError;

  /// No description provided for @exportImportExportEncryptionError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t encrypt the backup. Please try again.'**
  String get exportImportExportEncryptionError;

  /// No description provided for @exportImportExportFileError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the backup file. Please try again.'**
  String get exportImportExportFileError;

  /// No description provided for @exportImportImportInvalidFileError.
  ///
  /// In en, this message translates to:
  /// **'This file isn\'t a valid notes backup.'**
  String get exportImportImportInvalidFileError;

  /// No description provided for @exportImportImportWrongPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Wrong password, or the backup is corrupted.'**
  String get exportImportImportWrongPasswordError;

  /// No description provided for @exportImportImportAuthError.
  ///
  /// In en, this message translates to:
  /// **'You need to be signed in to import notes.'**
  String get exportImportImportAuthError;

  /// No description provided for @exportImportImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Notes imported successfully'**
  String get exportImportImportSuccess;

  /// No description provided for @exportImportImportDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Notes'**
  String get exportImportImportDialogTitle;

  /// No description provided for @exportImportImportDialogPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty if backup has no password'**
  String get exportImportImportDialogPasswordHint;

  /// No description provided for @exportImportImportDialogPasswordFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Password (if encrypted)'**
  String get exportImportImportDialogPasswordFieldHint;

  /// No description provided for @exportImportImportDialogPolicyLabel.
  ///
  /// In en, this message translates to:
  /// **'When a note already exists:'**
  String get exportImportImportDialogPolicyLabel;

  /// No description provided for @exportImportImportPolicyMergeTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge content'**
  String get exportImportImportPolicyMergeTitle;

  /// No description provided for @exportImportImportPolicyMergeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Append imported text below the existing note'**
  String get exportImportImportPolicyMergeSubtitle;

  /// No description provided for @exportImportImportPolicyKeepIncomingTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep imported'**
  String get exportImportImportPolicyKeepIncomingTitle;

  /// No description provided for @exportImportImportPolicyKeepIncomingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Overwrite existing notes with the imported ones'**
  String get exportImportImportPolicyKeepIncomingSubtitle;

  /// No description provided for @exportImportImportPolicyKeepExistingTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep existing'**
  String get exportImportImportPolicyKeepExistingTitle;

  /// No description provided for @exportImportImportPolicyKeepExistingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Skip imported notes that already exist locally'**
  String get exportImportImportPolicyKeepExistingSubtitle;

  /// No description provided for @exportImportPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {count} characters'**
  String exportImportPasswordTooShort(String count);

  /// No description provided for @exportImportNoPasswordWarning.
  ///
  /// In en, this message translates to:
  /// **'Without a password, notes will be exported as plain text and anyone with the file can read them.'**
  String get exportImportNoPasswordWarning;

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

  /// No description provided for @notesListDecryptLikelyReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Likely reason'**
  String get notesListDecryptLikelyReasonLabel;

  /// No description provided for @notesListDecryptDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get notesListDecryptDetailsLabel;

  /// No description provided for @notesListDecryptReasonWrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN/password or a mismatched encryption context for this note.'**
  String get notesListDecryptReasonWrongPin;

  /// No description provided for @notesListDecryptReasonCorruptedPayload.
  ///
  /// In en, this message translates to:
  /// **'The note payload appears corrupted, incomplete, or produced by an unsupported format.'**
  String get notesListDecryptReasonCorruptedPayload;

  /// No description provided for @notesListDecryptReasonInvalidParams.
  ///
  /// In en, this message translates to:
  /// **'Cryptographic parameters are invalid for this note.'**
  String get notesListDecryptReasonInvalidParams;

  /// No description provided for @notesListSomeNotesDecryptFailed.
  ///
  /// In en, this message translates to:
  /// **'Some notes couldn\'t be decrypted. Check your PIN.'**
  String get notesListSomeNotesDecryptFailed;

  /// No description provided for @editNoteScreenSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Note saved successfully!'**
  String get editNoteScreenSaveSuccess;

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
  /// **'# Private Notes (Nostr)\n\nPrivate Notes (Nostr) is a private, encrypted note-taking app built on the **Nostr** protocol. Your notes are encrypted on your device and synced through decentralized relays — no company owns your data.\n\n\n## What is Nostr?\n\nNostr (Notes and Other Stuff Transmitted by Relays) is an open, decentralized protocol. Instead of a central server, it uses a network of **relays** — independent servers that store and forward your data. Your identity is a cryptographic key pair, not an email or phone number.\n\n\n## Key Concepts\n\n### 🔑 Nsec (Private Key)\n\nYour **nsec** is your master key. It starts with `nsec1...` and is the bech32 encoding of your private key (hex). It is used to:\n\n- **Sign** your notes so relays can verify they come from you\n- **Encrypt** and **decrypt** your note content\n- **Prove ownership** of your account\n\n> ⚠️ **Never share your nsec with anyone.** Anyone who has it gains full control of your account. There is no \"forgot password\" — if you lose your nsec, your data is gone forever.\n\nYour nsec is stored only on this device in secure storage (Keychain on iOS, Keystore on Android). It is never sent to any server.\n\n### 🌐 Public Key (npub)\n\nYour **public key** (displayed as `npub1...`) is your public identity on the Nostr network. It is derived from your nsec and is safe to share. Anyone can use it to look up your profile across Nostr apps.\n\n### 🔒 PIN / Password\n\nThe PIN provides an **extra layer of encryption** on top of your nsec. Even if someone obtains your private key, they still cannot read your notes without the PIN.\n\nImportant details:\n\n- The PIN is **never saved to disk** — it lives only in memory while the app is open\n- If you **forget your PIN**, existing notes **cannot be decrypted**\n- If you enter a **wrong PIN**, new or edited notes will be encrypted with that incorrect PIN, making them unreadable with the correct one\n\n### 📡 Relays\n\nRelays are servers that store and deliver your encrypted notes. You can choose which relays to use in **Settings → Preferences → Connected Relays**. Using multiple relays increases redundancy — if one goes offline, your data is still available on others.\n\n\n## How It Works\n\n1. **Create** a note in the editor\n2. The note is **encrypted** on your device using NIP-44 encryption with your nsec and PIN\n3. The encrypted note is **signed** and **published** to your selected relays\n4. When you open the app, notes are **fetched** from relays and **decrypted** locally\n\nNo one — not the relay operators, not us — can read your notes. Only you, with your nsec and PIN, can decrypt them.\n\n\n## Tips\n\n- **Back up your nsec** in a secure place (e.g., a password manager). Without it, your account cannot be recovered.\n- **Remember your PIN.** It is not stored anywhere and cannot be reset.\n- **Use multiple relays** for better availability and redundancy.\n- Your nsec works across all Nostr apps — you can use the same identity everywhere.'**
  String get helpScreenContent;

  /// No description provided for @notesListScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesListScreenTitle;

  /// No description provided for @notesListTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notesListTabAll;

  /// No description provided for @notesListTabFolders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get notesListTabFolders;

  /// No description provided for @notesFoldersEmptyStatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Assign labels to notes to organize them into folders'**
  String get notesFoldersEmptyStatePlaceholder;

  /// No description provided for @homeScreenEmptyStatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tap + to start writing'**
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

  /// No description provided for @notesListConfirmationDialogDeletion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note? This action cannot be undone.'**
  String get notesListConfirmationDialogDeletion;

  /// No description provided for @notesListAssignFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get notesListAssignFolder;

  /// No description provided for @privacyPolicyScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyScreenTitle;

  /// No description provided for @classificationClassFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get classificationClassFinance;

  /// No description provided for @classificationClassJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get classificationClassJournal;

  /// No description provided for @classificationClassPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get classificationClassPersonal;

  /// No description provided for @classificationClassSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get classificationClassSecurity;

  /// No description provided for @classificationClassTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get classificationClassTravel;

  /// No description provided for @classificationClassWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get classificationClassWork;

  /// No description provided for @classificationClassBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get classificationClassBookmarks;

  /// No description provided for @classificationClassOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get classificationClassOther;

  /// No description provided for @notePreviewMoreMenuAssignFolder.
  ///
  /// In en, this message translates to:
  /// **'Assign folder'**
  String get notePreviewMoreMenuAssignFolder;

  /// No description provided for @notePreviewMoreMenuCopyContent.
  ///
  /// In en, this message translates to:
  /// **'Copy content'**
  String get notePreviewMoreMenuCopyContent;

  /// No description provided for @notePreviewMoreMenuInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get notePreviewMoreMenuInfo;

  /// No description provided for @donateLightningScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Donate via Lightning ⚡'**
  String get donateLightningScreenTitle;

  /// No description provided for @donateLightningScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Support development with a lightning payment'**
  String get donateLightningScreenSubtitle;

  /// No description provided for @donateLightningScreenErrorInvoice.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate invoice'**
  String get donateLightningScreenErrorInvoice;

  /// No description provided for @donateLightningScreenInputHint.
  ///
  /// In en, this message translates to:
  /// **'Amount (sats)'**
  String get donateLightningScreenInputHint;

  /// No description provided for @donateLightningScreenWalletSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Open in wallet'**
  String get donateLightningScreenWalletSectionTitle;

  /// No description provided for @donateLightningScreenSubmitButtonOpenInWallet.
  ///
  /// In en, this message translates to:
  /// **'Open in {walletName}'**
  String donateLightningScreenSubmitButtonOpenInWallet(String walletName);

  /// No description provided for @donateLightningScreenSubmitButtonGenerateInvoice.
  ///
  /// In en, this message translates to:
  /// **'Generate invoice'**
  String get donateLightningScreenSubmitButtonGenerateInvoice;

  /// No description provided for @donateLightningScreenButtonEditAmount.
  ///
  /// In en, this message translates to:
  /// **'Edit amount'**
  String get donateLightningScreenButtonEditAmount;

  /// No description provided for @donateLightningScreenButtonCopyInvoice.
  ///
  /// In en, this message translates to:
  /// **'Copy invoice'**
  String get donateLightningScreenButtonCopyInvoice;

  /// No description provided for @donateLightningScreenButtonOpenWithLightning.
  ///
  /// In en, this message translates to:
  /// **'Open with Lightning'**
  String get donateLightningScreenButtonOpenWithLightning;

  /// No description provided for @donateLightningScreenQrInstruction.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code with your Lightning wallet app on your phone.'**
  String get donateLightningScreenQrInstruction;

  /// No description provided for @donateLightningScreenMessageInvoiceCopied.
  ///
  /// In en, this message translates to:
  /// **'Invoice copied to clipboard'**
  String get donateLightningScreenMessageInvoiceCopied;
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
      <String>['bg', 'en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bg':
      return AppLocalizationsBg();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
