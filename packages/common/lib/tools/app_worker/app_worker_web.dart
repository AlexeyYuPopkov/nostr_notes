import 'dart:async';
import 'package:flutter/foundation.dart';
import 'app_worker.dart';

final class AppWorkerWeb implements AppWorker {
  const AppWorkerWeb();
  @override
  Future<R> compute<M, R>({
    required M params,
    required ComputeCallback<M, R> callback,
  }) async {
    return callback(params);
  }

  @override
  Future<void> dispose() => Future.value();

  @override
  Future<void> init() => Future.value();
}

final class AppWorkerImpl implements AppWorker {
  const AppWorkerImpl();
  @override
  Future<R> compute<M, R>({
    required M params,
    required ComputeCallback<M, R> callback,
  }) async {
    return callback(params);
  }

  @override
  Future<void> dispose() => Future.value();

  @override
  Future<void> init() => Future.value();
}
