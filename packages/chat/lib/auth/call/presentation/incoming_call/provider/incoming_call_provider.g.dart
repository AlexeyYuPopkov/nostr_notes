// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incoming_call_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The ringing invite [callId] from [callerPubkey].

@ProviderFor(IncomingCallProvider)
final incomingCallProviderProvider = IncomingCallProviderFamily._();

/// The ringing invite [callId] from [callerPubkey].
final class IncomingCallProviderProvider
    extends $NotifierProvider<IncomingCallProvider, IncomingCallData> {
  /// The ringing invite [callId] from [callerPubkey].
  IncomingCallProviderProvider._({
    required IncomingCallProviderFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'incomingCallProviderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$incomingCallProviderHash();

  @override
  String toString() {
    return r'incomingCallProviderProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  IncomingCallProvider create() => IncomingCallProvider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IncomingCallData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IncomingCallData>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IncomingCallProviderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$incomingCallProviderHash() =>
    r'0564d5ec11983273ec5d11040e3e7f0347690cad';

/// The ringing invite [callId] from [callerPubkey].

final class IncomingCallProviderFamily extends $Family
    with
        $ClassFamilyOverride<
          IncomingCallProvider,
          IncomingCallData,
          IncomingCallData,
          IncomingCallData,
          (String, String)
        > {
  IncomingCallProviderFamily._()
    : super(
        retry: null,
        name: r'incomingCallProviderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The ringing invite [callId] from [callerPubkey].

  IncomingCallProviderProvider call(String callerPubkey, String callId) =>
      IncomingCallProviderProvider._(
        argument: (callerPubkey, callId),
        from: this,
      );

  @override
  String toString() => r'incomingCallProviderProvider';
}

/// The ringing invite [callId] from [callerPubkey].

abstract class _$IncomingCallProvider extends $Notifier<IncomingCallData> {
  late final _$args = ref.$arg as (String, String);
  String get callerPubkey => _$args.$1;
  String get callId => _$args.$2;

  IncomingCallData build(String callerPubkey, String callId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<IncomingCallData, IncomingCallData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<IncomingCallData, IncomingCallData>,
              IncomingCallData,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
