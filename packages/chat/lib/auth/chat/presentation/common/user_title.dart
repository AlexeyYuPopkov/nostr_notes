import 'package:common/domain/model/user.dart';
import 'package:common/presentation/account_avatar.dart';
import 'package:nostr/key_tool/key_tool.dart';

extension UserTitle on User {
  /// The display name or name, if any.
  String? get readableName => [displayName, name]
      .whereType<String>()
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .firstOrNull;

  String get shortNpub => truncatePubkey(KeyTool.npubKey(pubkey));

  String get title => readableName ?? shortNpub;
}
