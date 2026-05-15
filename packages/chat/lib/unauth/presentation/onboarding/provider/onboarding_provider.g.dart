// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OnboardingProvider)
final onboardingProviderProvider = OnboardingProviderProvider._();

final class OnboardingProviderProvider
    extends $NotifierProvider<OnboardingProvider, OnboardingState> {
  OnboardingProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingProviderHash();

  @$internal
  @override
  OnboardingProvider create() => OnboardingProvider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingState>(value),
    );
  }
}

String _$onboardingProviderHash() =>
    r'76f1085c1338bb49b503d3239d96a59083457968';

abstract class _$OnboardingProvider extends $Notifier<OnboardingState> {
  OnboardingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OnboardingState, OnboardingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OnboardingState, OnboardingState>,
              OnboardingState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
