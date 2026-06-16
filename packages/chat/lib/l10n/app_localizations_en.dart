// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appDisplayName => 'Encrypted Chat (Nostr)';

  @override
  String get notUnlocked => 'The app is not unlocked';

  @override
  String get notePreviewCannotDecryptTitle =>
      'This message could not be decrypted';

  @override
  String get notePreviewCannotDecryptDescription =>
      'Messages are encrypted with NIP-44. Decryption may fail due to a key mismatch, data corruption, or if the message was sent from a different identity.';

  @override
  String get onboardingWelcomePageTitle => 'Welcome to\nEncrypted Chat (Nostr)';

  @override
  String get onboardingWelcomePageDescription =>
      'Send private messages – encrypted, decentralized, without intermediaries';

  @override
  String get onboardingWelcomePageOptionMD1 =>
      '💬 **Send** encrypted direct messages';

  @override
  String get onboardingWelcomePageOptionMD2 =>
      '🔐 **Encrypted** end-to-end with **NIP-44**';

  @override
  String get onboardingWelcomePageOptionMD3 =>
      '🌐 **Delivered** via Nostr relays';

  @override
  String get onboardingWelcomePageOptionMD4 =>
      '🔑 **Access** with your **nsec** key';

  @override
  String get onboardingWelcomeButtonNext => 'Get Started';

  @override
  String get onboardingWelcomeButtonHelp => 'Help';

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
  String get onboardingNsecPageValidationEmpty => 'NSEC key cannot be empty';

  @override
  String get onboardingNsecPageValidationNpub =>
      'This is a public key (npub). Please enter your private key (nsec)';

  @override
  String get onboardingNsecPageValidationInvalid => 'Invalid NSEC key';
}
