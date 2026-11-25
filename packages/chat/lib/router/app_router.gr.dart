// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:auto_route/auto_route.dart' as _i3;
import 'package:chat/auth/call/domain/models/call_direction.dart' as _i6;
import 'package:chat/router/auth_router.dart' as _i1;
import 'package:chat/unauth/presentation/onboarding/onboarding_screen.dart'
    as _i2;
import 'package:material_ui/material_ui.dart' as _i4;
import 'package:webrtc_call/webrtc_call.dart' as _i5;

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
/// [_i1.CallPage]
class CallRoute extends _i3.PageRouteInfo<CallRouteArgs> {
  CallRoute({
    _i4.Key? key,
    required String peerPubkey,
    required _i5.CallMedia media,
    required _i6.CallDirection direction,
    List<_i3.PageRouteInfo>? children,
  }) : super(
         CallRoute.name,
         args: CallRouteArgs(
           key: key,
           peerPubkey: peerPubkey,
           media: media,
           direction: direction,
         ),
         initialChildren: children,
       );

  static const String name = 'CallRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CallRouteArgs>();
      return _i1.CallPage(
        key: args.key,
        peerPubkey: args.peerPubkey,
        media: args.media,
        direction: args.direction,
      );
    },
  );
}

class CallRouteArgs {
  const CallRouteArgs({
    this.key,
    required this.peerPubkey,
    required this.media,
    required this.direction,
  });

  final _i4.Key? key;

  final String peerPubkey;

  final _i5.CallMedia media;

  final _i6.CallDirection direction;

  @override
  String toString() {
    return 'CallRouteArgs{key: $key, peerPubkey: $peerPubkey, media: $media, direction: $direction}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CallRouteArgs) return false;
    return key == other.key &&
        peerPubkey == other.peerPubkey &&
        media == other.media &&
        direction == other.direction;
  }

  @override
  int get hashCode =>
      key.hashCode ^ peerPubkey.hashCode ^ media.hashCode ^ direction.hashCode;
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
/// [_i1.IncomingCallPage]
class IncomingCallRoute extends _i3.PageRouteInfo<IncomingCallRouteArgs> {
  IncomingCallRoute({
    _i4.Key? key,
    required String callerPubkey,
    required String callId,
    required _i5.CallMedia media,
    required DateTime expiresAt,
    List<_i3.PageRouteInfo>? children,
  }) : super(
         IncomingCallRoute.name,
         args: IncomingCallRouteArgs(
           key: key,
           callerPubkey: callerPubkey,
           callId: callId,
           media: media,
           expiresAt: expiresAt,
         ),
         initialChildren: children,
       );

  static const String name = 'IncomingCallRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<IncomingCallRouteArgs>();
      return _i1.IncomingCallPage(
        key: args.key,
        callerPubkey: args.callerPubkey,
        callId: args.callId,
        media: args.media,
        expiresAt: args.expiresAt,
      );
    },
  );
}

class IncomingCallRouteArgs {
  const IncomingCallRouteArgs({
    this.key,
    required this.callerPubkey,
    required this.callId,
    required this.media,
    required this.expiresAt,
  });

  final _i4.Key? key;

  final String callerPubkey;

  final String callId;

  final _i5.CallMedia media;

  final DateTime expiresAt;

  @override
  String toString() {
    return 'IncomingCallRouteArgs{key: $key, callerPubkey: $callerPubkey, callId: $callId, media: $media, expiresAt: $expiresAt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IncomingCallRouteArgs) return false;
    return key == other.key &&
        callerPubkey == other.callerPubkey &&
        callId == other.callId &&
        media == other.media &&
        expiresAt == other.expiresAt;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      callerPubkey.hashCode ^
      callId.hashCode ^
      media.hashCode ^
      expiresAt.hashCode;
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
/// [_i1.ProfilePage]
class ProfileRoute extends _i3.PageRouteInfo<void> {
  const ProfileRoute({List<_i3.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i1.ProfilePage();
    },
  );
}

/// generated route for
/// [_i1.RelaysListPage]
class RelaysListRoute extends _i3.PageRouteInfo<void> {
  const RelaysListRoute({List<_i3.PageRouteInfo>? children})
    : super(RelaysListRoute.name, initialChildren: children);

  static const String name = 'RelaysListRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i1.RelaysListPage();
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
