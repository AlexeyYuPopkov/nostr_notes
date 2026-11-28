// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A call with [peerPubkey]; it ends when the provider is disposed.
///
/// An outgoing call also follows its invite: a decline from the peer ends
/// the call, and hanging up before the peer answered cancels the invite.

@ProviderFor(CallProvider)
final callProviderProvider = CallProviderFamily._();

/// A call with [peerPubkey]; it ends when the provider is disposed.
///
/// An outgoing call also follows its invite: a decline from the peer ends
/// the call, and hanging up before the peer answered cancels the invite.
final class CallProviderProvider
    extends $NotifierProvider<CallProvider, CallState> {
  /// A call with [peerPubkey]; it ends when the provider is disposed.
  ///
  /// An outgoing call also follows its invite: a decline from the peer ends
  /// the call, and hanging up before the peer answered cancels the invite.
  CallProviderProvider._({
    required CallProviderFamily super.from,
    required (String, CallMedia, CallDirection) super.argument,
  }) : super(
         retry: null,
         name: r'callProviderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$callProviderHash();

  @override
  String toString() {
    return r'callProviderProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  CallProvider create() => CallProvider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CallState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CallState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CallProviderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$callProviderHash() => r'f12cad32e2549a1787af0c737dab65fe97e2b154';

/// A call with [peerPubkey]; it ends when the provider is disposed.
///
/// An outgoing call also follows its invite: a decline from the peer ends
/// the call, and hanging up before the peer answered cancels the invite.

final class CallProviderFamily extends $Family
    with
        $ClassFamilyOverride<
          CallProvider,
          CallState,
          CallState,
          CallState,
          (String, CallMedia, CallDirection)
        > {
  CallProviderFamily._()
    : super(
        retry: null,
        name: r'callProviderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A call with [peerPubkey]; it ends when the provider is disposed.
  ///
  /// An outgoing call also follows its invite: a decline from the peer ends
  /// the call, and hanging up before the peer answered cancels the invite.

  CallProviderProvider call(
    String peerPubkey,
    CallMedia media,
    CallDirection direction,
  ) => CallProviderProvider._(
    argument: (peerPubkey, media, direction),
    from: this,
  );

  @override
  String toString() => r'callProviderProvider';
}

/// A call with [peerPubkey]; it ends when the provider is disposed.
///
/// An outgoing call also follows its invite: a decline from the peer ends
/// the call, and hanging up before the peer answered cancels the invite.

abstract class _$CallProvider extends $Notifier<CallState> {
  late final _$args = ref.$arg as (String, CallMedia, CallDirection);
  String get peerPubkey => _$args.$1;
  CallMedia get media => _$args.$2;
  CallDirection get direction => _$args.$3;

  CallState build(String peerPubkey, CallMedia media, CallDirection direction);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CallState, CallState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CallState, CallState>,
              CallState,
              Object?,
              Object?
            >;
    return element.handleCreate(
      ref,
      () => build(_$args.$1, _$args.$2, _$args.$3),
    );
  }
}
