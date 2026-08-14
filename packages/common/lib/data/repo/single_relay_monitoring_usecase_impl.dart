import 'package:nostr/model/relay_health.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/single_relay_monitor.dart';
import 'package:nostr_notes/common/domain/relay_validator.dart';
import 'package:common/domain/usecases/single_relay_monitoring_usecase.dart';

final class SingleRelayMonitoringUsecaseImpl
    with RelayValidator
    implements SingleRelayMonitoringUsecase {
  final ChannelFactory channelFactory;
  final Uri uri;

  late final SingleRelayMonitor _monitor = SingleRelayMonitor(
    url: uri,
    channelFactory: channelFactory,
    timeout: const Duration(seconds: 5),
  );
  bool _isMonitoring = false;

  SingleRelayMonitoringUsecaseImpl({
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
