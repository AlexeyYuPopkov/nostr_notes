// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_relays_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OnboardingRelaysProvider)
final onboardingRelaysVmProvider = OnboardingRelaysVmProvider._();

final class OnboardingRelaysVmProvider
    extends $NotifierProvider<OnboardingRelaysProvider, OnboardingRelaysState> {
  OnboardingRelaysVmProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingRelaysVmProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingRelaysVmHash();

  @$internal
  @override
  OnboardingRelaysProvider create() => OnboardingRelaysProvider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingRelaysState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingRelaysState>(value),
    );
  }
}

String _$onboardingRelaysVmHash() =>
    r'7168f91181d229aeeed8f5c3f0cf636dba03f5da';

abstract class _$OnboardingRelaysVm extends $Notifier<OnboardingRelaysState> {
  OnboardingRelaysState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OnboardingRelaysState, OnboardingRelaysState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OnboardingRelaysState, OnboardingRelaysState>,
              OnboardingRelaysState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
