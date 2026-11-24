// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relays_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RelaysProvider)
final relaysProviderProvider = RelaysProviderProvider._();

final class RelaysProviderProvider
    extends $NotifierProvider<RelaysProvider, RelaysState> {
  RelaysProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'relaysProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$relaysProviderHash();

  @$internal
  @override
  RelaysProvider create() => RelaysProvider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RelaysState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RelaysState>(value),
    );
  }
}

String _$relaysProviderHash() => r'b392ab97e26759e4b890af37302797a4c1690324';

abstract class _$RelaysProvider extends $Notifier<RelaysState> {
  RelaysState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RelaysState, RelaysState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RelaysState, RelaysState>,
              RelaysState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
