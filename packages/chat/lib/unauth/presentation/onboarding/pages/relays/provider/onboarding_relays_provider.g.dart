// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_relays_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OnboardingRelaysProvider)
final onboardingRelaysProviderProvider = OnboardingRelaysProviderProvider._();

final class OnboardingRelaysProviderProvider
    extends $NotifierProvider<OnboardingRelaysProvider, OnboardingRelaysState> {
  OnboardingRelaysProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingRelaysProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingRelaysProviderHash();

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

String _$onboardingRelaysProviderHash() =>
    r'93a0559e2913f123ad67ab9e25ddda0e90042551';

abstract class _$OnboardingRelaysProvider
    extends $Notifier<OnboardingRelaysState> {
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
