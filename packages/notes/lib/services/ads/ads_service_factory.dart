import 'dart:io';

import 'package:flutter/foundation.dart';

import 'ads_service.dart';
import 'ads_service_ios.dart';
import 'ads_service_stub.dart';

AdsService createAdsService() {
  if (kIsWeb) return const AdsServiceStub();
  if (Platform.isIOS) return AdsServiceIos();
  return const AdsServiceStub();
}
