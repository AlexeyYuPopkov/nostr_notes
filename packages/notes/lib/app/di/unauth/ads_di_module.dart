import 'dart:async';

import 'package:di_storage/di_storage.dart';
import 'package:nostr_notes/services/ads/ads_service.dart';
import 'package:nostr_notes/services/ads/ads_service_factory.dart';

final class AdsDiModule extends DiScope {
  const AdsDiModule();

  @override
  FutureOr<void> bind(DiStorage di) async {
    final service = createAdsService();
    await service.initialize();
    di.bind<AdsService>(
      () => service,
      module: this,
      lifeTime: const LifeTime.single(),
    );
  }
}
