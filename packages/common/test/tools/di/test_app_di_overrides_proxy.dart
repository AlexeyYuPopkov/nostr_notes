import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:di_storage/di_storage.dart';
import 'package:nostr_notes/app/di/app_di.dart';
import 'package:nostr_notes/app/di/unauth/db_module.dart';
import 'package:nostr_notes/services/outbox_publisher.dart';
import 'package:rxdart/rxdart.dart';
import 'in_memory_db_module.dart';

final class TestAppDiOverridesProxy implements Di {
  const TestAppDiOverridesProxy();

  @override
  Future<void> bindAuthModules() async {
    await const AppDi().bindAuthModules(
      testOverrides: (di) {
        di.bind<Connectivity>(
          () => MockConnectivity(results: [ConnectivityResult.wifi]),
          module: null,
          lifeTime: const LifeTime.single(),
        );

        di.bind<OutboxPublisher>(
          () => NoopOutboxPublisher(),
          module: null,
          lifeTime: const LifeTime.single(),
        );
      },
    );
  }

  @override
  Future<void> bindUnauthModules() async {
    await const AppDi().bindUnauthModules();
    final di = DiStorage.shared;
    di.removeScope<DbModule>();
    const InMemoryDbModule().bind(di);
  }

  @override
  void removeAuthModules() {
    return const AppDi().removeAuthModules();
  }

  @override
  void removeUnauthModules() {
    return const AppDi().removeUnauthModules();
  }
}

class MockConnectivity implements Connectivity {
  final List<ConnectivityResult> results;

  MockConnectivity({required this.results});

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => results;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.value(results).shareReplay(maxSize: 1);
}
