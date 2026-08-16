import 'dart:async';

import 'package:common/domain/repo/app_lifecycle_listener_repository.dart';
import 'package:common/domain/usecases/relays_monitoring_usecase.dart';
import 'package:nostr/model/relay_health.dart';
import 'package:nostr/nostr_client/relays_monitor.dart';

final class RelaysMonitoringUsecaseImpl implements RelaysMonitoringUsecase {
  final RelaysMonitor _monitor;
  final AppLifecycleListenerRepository _lifecycle;
  late final StreamSubscription<bool> _lifecycleSub;

  RelaysMonitoringUsecaseImpl({
    required RelaysMonitor monitor,
    required AppLifecycleListenerRepository lifecycle,
  }) : _monitor = monitor,
       _lifecycle = lifecycle {
    _lifecycleSub = _lifecycle.isActiveStream.listen((isActive) {
      if (isActive) {
        _monitor.resume();
      } else {
        _monitor.pause();
      }
    });
  }

  @override
  Stream<Map<String, RelayStatus>> get statuses => _monitor.statuses;

  @override
  Future<void> dispose() async {
    await _lifecycleSub.cancel();
    await _monitor.dispose();
  }
}
