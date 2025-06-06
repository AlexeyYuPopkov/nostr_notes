import 'package:nostr_notes/services/key_tool/key_tool.dart';
import 'package:nostr_notes/unauth/domain/validators/nsec_validator.dart';

final class NsecValidatorImpl implements NsecValidator {
  const NsecValidatorImpl();

  @override
  InvalidNsecError? validate(String? nsecKey) {
    final result = KeyTool.tryDecodeNsecKeyToPrivateKey(nsecKey);
    return result == null || result.isEmpty ? const InvalidNsecError() : null;
  }
}
