import 'package:nostr/model/relay_health.dart';
import 'package:nostr_notes/common/domain/relay_validator.dart';

abstract interface class SingleRelayMonitoringUsecase {
  Future<void> dispose();

  bool isValidRelayUrl(String url);
  RelayValidatorError? validateRelayUrl(String url);

  Future<RelayHealth> canConnect();
  Stream<RelayHealth> health();
}
