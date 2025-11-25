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
  String get onboardingPinPageTitle => 'Set a PIN or password';

  @override
  String get onboardingPinPageDescription =>
      'This is used for an additional layer of encryption – even if someone obtains your nsec, your notes will remain protected';

  @override
  String get onboardingPinPageTextFieldHint => 'PIN or password';

  @override
  String get onboardingPinPageLabelCheckboxUsePin => 'Use pin to unlock app';

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
      'Do you really want to log out and clear all data? This action cannot be undone';

  @override
  String get noteScreenErrorNoteContentCannotBeEmpty =>
      'Note content cannot be empty';

  @override
  String get errorPublishOperationTimedOut => 'Publish operation timed out';
}
