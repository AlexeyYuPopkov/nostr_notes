import 'package:flutter/material.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/common/presentation/markdown_screen.dart';

final class PrivacyPolicyScreen extends StatelessWidget {
  static const _text = '''
  # Privacy Policy for Private Notes (Nostr)

  **Effective Date:** March 16, 2026

  ## Introduction

  This privacy policy applies to the Private Notes (Nostr) application (hereinafter referred to as the "Application") for mobile devices, created by Alekseii Popkov (hereinafter referred to as the "Service Provider"). The Application is provided as a free service and is intended for use "AS IS".

  ## No Data Collection by the Service Provider

  The Service Provider **does not collect, store, or share any personal data** from users of the Application.

  The Application is designed with a "zero-knowledge" architecture:

  - All notes are encrypted on your device before being transmitted
  - The Service Provider does not operate servers that store your data
  - The Service Provider cannot access your notes, private keys (nsec), or PIN

  ## How the Application Works with Nostr Protocol

  Private Notes (Nostr) uses the Nostr protocol — a decentralized network of independent servers called "relays."

  Your private key (nsec) is generated on your device and stored exclusively in secure hardware-backed storage (Keychain on iOS, Keystore on Android). It never leaves your device and is never sent to the Service Provider or any third party.

  Your notes are encrypted locally and then published to Nostr relays that you select in the Application settings.

  Relay operators may temporarily store your encrypted notes, but they cannot read them — only you can decrypt them with your nsec and optional PIN.

  **Optional PIN:** If you choose to set a PIN for additional security, it is never stored on disk and exists only in memory while the Application is open.

  ## What Information Is Visible

  Your public key (npub) is visible to relays and other Nostr users when you publish notes. This is a public identifier, similar to a username.

  The Service Provider does not collect your npub, IP address, device information, or usage statistics.

  ## Third-Party Access

  The Application does not integrate any third-party analytics, crash reporting, advertising SDKs, or tracking tools.

  The Service Provider does not share any user data with third parties because no user data is collected.

  Nostr relays (which you choose independently) may process your encrypted data according to their own policies. The Service Provider is not responsible for the privacy practices of these relays.

  ## Opt-Out Rights

  You can stop all use of the Application simply by uninstalling it. Use the standard uninstall process available on your mobile device or via the app marketplace.

  ## Data Retention and Deletion

  Your notes and nsec remain solely on your device and the relays you selected.

  To delete your data permanently, uninstall the Application and, if desired, send deletion requests to your chosen relays.

  The Service Provider cannot delete your data because the Service Provider does not possess it.

  ## Children's Privacy

  The Application is not directed at children under the age of 13. The Service Provider does not knowingly collect any information from children. If you believe a child has provided personally identifiable information, contact the Service Provider at alexey.yu.popkov@gmail.com — although please note that the Service Provider does not collect such information.

  ## Security

  The Service Provider is committed to protecting your privacy through transparency and minimal data handling. Your data's security relies on:

  - On-device encryption using modern standards (NIP-44)
  - Hardware-backed secure storage for private keys
  - User control over relay selection

  However, you are solely responsible for backing up your nsec. If lost, your notes cannot be recovered by anyone, including the Service Provider.

  ## Changes to This Privacy Policy

  This Privacy Policy may be updated from time to time. The Service Provider will notify you of any changes by updating this page with the new policy. Continued use of the Application is deemed approval of the updated policy.

  ## Your Consent

  By using the Application, you consent to the processing of your information as described in this Privacy Policy. Since the Service Provider does not collect data, this primarily means you consent to the local encryption and relay-based distribution of your notes.

  ## Contact Us

  If you have any questions regarding privacy while using the Application, please contact the Service Provider at:

  📧 alexey.yu.popkov@gmail.com
''';

  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // createPrivacyPolicyScreen
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyPolicyScreenTitle),
        leading: const SizedBox(),
      ),
      body: const Center(child: MarkdownScreenContent(content: _text)),
    );
  }
}
