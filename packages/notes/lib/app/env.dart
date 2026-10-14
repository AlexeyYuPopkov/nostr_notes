import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract final class Env {
  @EnviedField(varName: 'DEV_LIGHTNING_ADDRESS')
  static final String devLightningAddress = _Env.devLightningAddress;

  @EnviedField(varName: 'DEV_NOSTR_PUBKEY')
  static final String devNostrPubkey = _Env.devNostrPubkey;

  @EnviedField(varName: 'KOFI_URL')
  static final String kofiUrl = _Env.kofiUrl;
}
