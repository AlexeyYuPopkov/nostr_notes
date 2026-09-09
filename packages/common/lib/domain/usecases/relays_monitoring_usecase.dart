import 'package:common/tools/disposable.dart';
import 'package:nostr/model/relay_health.dart';

/// Fleet-wide relay status for a small always-visible connectivity
/// indicator — see `RelaysMonitor` (nostr package) for the underlying
/// mechanism this wraps with app-lifecycle awareness (pausing the probe
/// ticker while the app is backgrounded).
abstract interface class RelaysMonitoringUsecase implements Disposable {
  Stream<Map<String, RelayStatus>> get statuses;
}
