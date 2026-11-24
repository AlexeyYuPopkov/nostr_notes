// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// An outgoing call to [peerPubkey]; it ends when the provider is disposed.

@ProviderFor(CallProvider)
final callProviderProvider = CallProviderFamily._();

/// An outgoing call to [peerPubkey]; it ends when the provider is disposed.
final class CallProviderProvider
    extends $NotifierProvider<CallProvider, CallState> {
  /// An outgoing call to [peerPubkey]; it ends when the provider is disposed.
  CallProviderProvider._({
    required CallProviderFamily super.from,
    required (String, CallMedia) super.argument,
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

String _$callProviderHash() => r'787d28bd1b16a9de6a882d308c6c3fccfbce1ad3';

/// An outgoing call to [peerPubkey]; it ends when the provider is disposed.

final class CallProviderFamily extends $Family
    with
        $ClassFamilyOverride<
          CallProvider,
          CallState,
          CallState,
          CallState,
          (String, CallMedia)
        > {
  CallProviderFamily._()
    : super(
        retry: null,
        name: r'callProviderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// An outgoing call to [peerPubkey]; it ends when the provider is disposed.

  CallProviderProvider call(String peerPubkey, CallMedia media) =>
      CallProviderProvider._(argument: (peerPubkey, media), from: this);

  @override
  String toString() => r'callProviderProvider';
}

/// An outgoing call to [peerPubkey]; it ends when the provider is disposed.

abstract class _$CallProvider extends $Notifier<CallState> {
  late final _$args = ref.$arg as (String, CallMedia);
  String get peerPubkey => _$args.$1;
  CallMedia get media => _$args.$2;

  CallState build(String peerPubkey, CallMedia media);
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
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
