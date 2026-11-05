// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:auto_route/auto_route.dart' as _i3;
import 'package:chat/router/auth_router.dart' as _i1;
import 'package:chat/unauth/presentation/onboarding/onboarding_screen.dart'
    as _i2;
import 'package:flutter/material.dart' as _i4;

/// generated route for
/// [_i1.AuthTabsPage]
class AuthTabsRoute extends _i3.PageRouteInfo<void> {
  const AuthTabsRoute({List<_i3.PageRouteInfo>? children})
    : super(AuthTabsRoute.name, initialChildren: children);

  static const String name = 'AuthTabsRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i1.AuthTabsPage();
    },
  );
}

/// generated route for
/// [_i1.ChatPage]
class ChatRoute extends _i3.PageRouteInfo<ChatRouteArgs> {
  ChatRoute({
    _i4.Key? key,
    required String pubkey,
    List<_i3.PageRouteInfo>? children,
  }) : super(
         ChatRoute.name,
         args: ChatRouteArgs(key: key, pubkey: pubkey),
         initialChildren: children,
       );

  static const String name = 'ChatRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatRouteArgs>();
      return _i1.ChatPage(key: args.key, pubkey: args.pubkey);
    },
  );
}

class ChatRouteArgs {
  const ChatRouteArgs({this.key, required this.pubkey});

  final _i4.Key? key;

  final String pubkey;

  @override
  String toString() {
    return 'ChatRouteArgs{key: $key, pubkey: $pubkey}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatRouteArgs) return false;
    return key == other.key && pubkey == other.pubkey;
  }

  @override
  int get hashCode => key.hashCode ^ pubkey.hashCode;
}

/// generated route for
/// [_i1.ChatsListPage]
class ChatsListRoute extends _i3.PageRouteInfo<void> {
  const ChatsListRoute({List<_i3.PageRouteInfo>? children})
    : super(ChatsListRoute.name, initialChildren: children);

  static const String name = 'ChatsListRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i1.ChatsListPage();
    },
  );
}

/// generated route for
/// [_i2.OnboardingScreen]
class OnboardingRoute extends _i3.PageRouteInfo<void> {
  const OnboardingRoute({List<_i3.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i2.OnboardingScreen();
    },
  );
}

/// generated route for
/// [_i1.SearchContactPage]
class SearchContactRoute extends _i3.PageRouteInfo<void> {
  const SearchContactRoute({List<_i3.PageRouteInfo>? children})
    : super(SearchContactRoute.name, initialChildren: children);

  static const String name = 'SearchContactRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i1.SearchContactPage();
    },
  );
}

/// generated route for
/// [_i1.SettingsPage]
class SettingsRoute extends _i3.PageRouteInfo<void> {
  const SettingsRoute({List<_i3.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i1.SettingsPage();
    },
  );
}
