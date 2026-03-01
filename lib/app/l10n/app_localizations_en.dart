// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get commonError => 'Error';

  @override
  String get commonAttention => 'Attention';

  @override
  String get commonUndefinedError => 'Something went wrong';

  @override
  String get commonNoDataPlaceholderText => 'No data';

  @override
  String get commonCopied => 'Copied';

  @override
  String get commonInfo => 'Information';

  @override
  String get authError => 'Authentication error';

  @override
  String get notUnlocked => 'The app is not unlocked';

  @override
  String get onboardingWelcomePageTitle => 'Welcome to\nNotesVault';

  @override
  String get onboardingWelcomePageDescription =>
      'Securely store short notes and passwords\n– encrypted, decentralized, just for you';

  @override
  String get onboardingWelcomePageOptionMD1 =>
      '✏️ **Create** short notes and passwords';

  @override
  String get onboardingWelcomePageOptionMD2 =>
      '🔐 **Encrypted** on your device';

  @override
  String get onboardingWelcomePageOptionMD3 => '🌐 **Stored** via Nostr';

  @override
  String get onboardingWelcomePageOptionMD4 =>
      '🧷 **Access** with your **nsec** and **PIN**';

  @override
  String get onboardingWelcomeButtonNext => 'Get Started';

  @override
  String get onboardingSignUpPageTitle => 'Sign Up with Nostr';

  @override
  String get onboardingSignUpPageSubtitle => 'What is Nostr?';

  @override
  String get onboardingSignUpPageDescription =>
      'Nostr is a decentralized network designed for secure and censorship-resistant communication. Unlike traditional platforms, Nostr doesn\'t rely on centralized servers—your identity and data belong to you.';

  @override
  String get onboardingSignUpPageWhyTitle => 'Why Sign Up with Nostr?';

  @override
  String get onboardingSignUpPageOptionMD1 =>
      '✅ **Instant Access** - One click generates your private key. No email or password required.';

  @override
  String get onboardingSignUpPageOptionMD2 =>
      '🔐 **You own your identity** - Your key is your identity. No company controls your account.';

  @override
  String get onboardingSignUpPageOptionMD3 =>
      '🌍 **Works Everywhere** - Use the same key across all Nostr-powered apps';

  @override
  String get onboardingSignUpButtonGenerateKey => 'Generate a Nostr Key';

  @override
  String get onboardingSignUpAlreadyHaveAccount => 'Already have an account?';

  @override
  String get onboardingSignUpButtonLogin => 'Log In';

  @override
  String get onboardingShowNsecPageTitle => 'Your Nostr Private Key (Nsec Key)';

  @override
  String get onboardingShowNsecPageDescription =>
      'Save this key securely. Your Nsec key gives you complete control and ownership of your data.';

  @override
  String get onboardingShowNsecPageOptionMD1 =>
      '🔑 **Required** – This key is your account password and is required to log in.';

  @override
  String get onboardingShowNsecPageOptionMD2 =>
      '📌 **Permanent** – Keep a secure backup. We cannot change or recover it.';

  @override
  String get onboardingShowNsecPageOptionMD3 =>
      '🚫 **Private** – Anyone with this key can access your account. Never share it.';

  @override
  String get onboardingShowNsecPageButtonCopyKey => 'Copy Key';

  @override
  String get onboardingShowNsecPageKeyCopied => 'Key copied to clipboard';

  @override
  String get onboardingNsecPageTitle => 'Enter your Nostr nsec';

  @override
  String get onboardingNsecPageDescription =>
      'Your private key is used to encrypt and sign notes. It is only yours and never leaves the device';

  @override
  String get onboardingNsecPageTextFieldHint => 'nsec1...';

  @override
  String get onboardingNsecPageLabelHint =>
      'You can import from another app or paste it manually';

  @override
  String get onboardingNsecPageDontHaveAccount => 'Don\'t have an account?';

  @override
  String get onboardingNsecPageButtonSignUp => 'Sign Up';

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
  String get onboardingPinPageTitle => 'Set a PIN or password';

  @override
  String get onboardingPinPageDescription =>
      'This is used for an additional layer of encryption – even if someone obtains your nsec, your notes will remain protected';

  @override
  String get onboardingPinPageTextFieldHint => 'PIN or password';

  @override
  String get onboardingPinPageLabelCheckboxUsePin => 'Use pin to unlock app';

  @override
  String get onboardingPinPageInfoPin =>
      'The PIN is an additional layer of protection against nsec compromise. It is stored only in memory and is never persisted. If the PIN is lost, your existing notes cannot be decrypted. If you create or edit a note with an incorrect PIN, that note will be encrypted with the wrong PIN.';

  @override
  String get errorEmptyNsec => 'NSEC key cannot be empty';

  @override
  String get errorInvalidNsecFormat => 'Invalid NSEC key format';

  @override
  String get errorInvalidPrivateKey => 'Invalid private key';

  @override
  String get errorEmptyPubkey => 'Public key cannot be empty';

  @override
  String get errorEmptyPin => 'PIN or password cannot be empty';

  @override
  String errorInvalidPinFormatMinCount(String minCount) {
    return 'PIN or password must be at least $minCount characters long';
  }

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get settingsScreenExit => 'Exit';

  @override
  String get settingsScreenLogout => 'Logout and clear data';

  @override
  String get settingsScreenLogoutConfirmationMessage =>
      'Do you really want to log out and clear all data? This action cannot be undone.\nMake sure you have saved your nsec and PIN — if you forget either, your data will be lost permanently.';

  @override
  String get settingsItemPreferences => 'Preferences';

  @override
  String get preferencesScreenItemRelays => 'Connected Relays';

  @override
  String get preferencesScreenItemMobilePinKeyboardType => 'PIN Keyboard Type';

  @override
  String get pinKeyboardTypeScreenTitle => 'PIN Keyboard Type';

  @override
  String get pinKeyboardTypeScreenDescription =>
      'Choose the keyboard type shown when entering your PIN';

  @override
  String get pinKeyboardTypeText => 'Default (Text)';

  @override
  String get pinKeyboardTypeNumber => 'Number';

  @override
  String get pinKeyboardTypePhone => 'Phone';

  @override
  String get noteScreenErrorNoteContentCannotBeEmpty =>
      'Note content cannot be empty';

  @override
  String get errorPublishOperationTimedOut => 'Publish operation timed out';

  @override
  String get notesListPendingSyncTitle => 'Sync pending';

  @override
  String get notesListPendingSyncDescription =>
      'This note hasn\'t been synced with the network yet';

  @override
  String get credentialsDataScreenTitle => 'Credentials Data';

  @override
  String get credentialsDataScreenLabelNsec => 'Nsec';

  @override
  String get credentialsDataScreenLabelPrivateKey => 'Private Key';

  @override
  String get credentialsDataScreenLabelPubKey => 'Public Key';

  @override
  String get credentialsDataScreenLabelPin => 'Pin';

  @override
  String get credentialsDataScreenWarningNsec =>
      'Your nsec (private key) is stored only on this device in secure storage (Keychain on iOS, Keystore on Android). It is never sent to any server. Losing your nsec means losing access to all your data permanently.';

  @override
  String get credentialsDataScreenWarningPin =>
      'The PIN is an additional layer of protection against nsec compromise. It is stored only in memory and is never persisted. If the PIN is lost, your existing notes cannot be decrypted. If you create or edit a note with an incorrect PIN, that note will be encrypted with the wrong PIN.';

  @override
  String get credentialsDataScreenWarningPrivateKey =>
      'The private key is a hex representation of your nsec. Both formats grant full access to your account.';

  @override
  String get notesListScreenTitle => 'Notes';

  @override
  String get homeScreenEmptyStatePlaceholder =>
      'Select a note or create a new one';
}
