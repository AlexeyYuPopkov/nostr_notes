import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:nostr_notes/app/router/app_route/app_route.dart';

class RouteHandler extends InheritedWidget {
  final RouterHelperVm vm;
  FutureOr<dynamic> Function(AppRoute, BuildContext) get onRoute => vm.onRoute;

  const RouteHandler({super.key, required super.child, required this.vm});

  static RouteHandler? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RouteHandler>();
  }

  @override
  bool updateShouldNotify(RouteHandler oldWidget) {
    return vm != oldWidget.vm;
  }
}

class RouteHandlerWidget extends StatelessWidget {
  final Widget child;
  final FutureOr<dynamic> Function(AppRoute, BuildContext) onRoute;
  const RouteHandlerWidget({
    super.key,
    required this.child,
    required this.onRoute,
  });

  @override
  Widget build(BuildContext context) {
    final vm = RouterHelperVm(onRoute);
    return RouteHandler(vm: vm, child: child);
  }
}

class RouterHelperVm {
  final FutureOr<dynamic> Function(AppRoute, BuildContext) onRoute;
  RouterHelperVm(this.onRoute);
}

final class UnhandledRouteResult implements AppRoute {
  const UnhandledRouteResult();
}
