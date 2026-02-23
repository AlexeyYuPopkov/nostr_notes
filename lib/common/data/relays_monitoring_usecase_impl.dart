import 'package:nostr_notes/common/domain/model/relay_health.dart';
import 'package:nostr_notes/common/domain/relay_validator.dart';
import 'package:nostr_notes/common/domain/relays_monitoring_usecase.dart';
import 'package:nostr_notes/services/nostr_client/channel_factory.dart';
import 'package:nostr_notes/services/nostr_client/relay_monitoring.dart';

final class RelaysMonitoringUsecaseImpl
    with RelayValidator
    implements RelaysMonitoringUsecase {
  final ChannelFactory channelFactory;
  final Uri uri;

  late final RelayMonitoring _monitor = RelayMonitoring(
    url: uri,
    channelFactory: channelFactory,
    timeout: const Duration(seconds: 5),
  );
  bool _isMonitoring = false;

  RelaysMonitoringUsecaseImpl({
    this.channelFactory = const ChannelFactory(),
    required this.uri,
  });

  @override
  Future<RelayHealth> canConnect() async {
    if (!_isMonitoring) {
      _monitor.start();
      _isMonitoring = true;
    }

    final health = await _monitor.currentStatus;
    return health;
  }

  @override
  Stream<RelayHealth> health() {
    if (!_isMonitoring) {
      _monitor.start();
      _isMonitoring = true;
    }

    return _monitor.status;
  }

  @override
  Future<void> dispose() async {
    await _monitor.dispose();
    _isMonitoring = false;
  }
}
