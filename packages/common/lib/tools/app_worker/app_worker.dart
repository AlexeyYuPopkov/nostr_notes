import 'dart:io';

import 'package:common/tools/disposable.dart';
import 'package:flutter/foundation.dart';

import 'dart:async';
import 'app_worker_impl.dart'
    if (dart.library.js_interop) 'app_worker_web.dart';

abstract interface class AppWorker implements Disposable {
  static AppWorker instance = AppWorker._create();

  static final kIsTest = kIsWeb
      ? false
      : Platform.environment.containsKey('FLUTTER_TEST') &&
            !const bool.fromEnvironment('INTEGRATION_TEST');

  Future<void> init();
  Future<R> compute<M, R>({
    required M params,
    required ComputeCallback<M, R> callback,
  });

  factory AppWorker._create() {
    if (kIsWeb || kIsTest) {
      return const AppWorkerWeb()..init();
    } else {
      return AppWorkerImpl()..init();
    }
  }
}
