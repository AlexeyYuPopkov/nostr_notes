// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OnboardingState)
final onboardingStateProvider = OnboardingStateProvider._();

final class OnboardingStateProvider
    extends $NotifierProvider<OnboardingState, OnboardingScreenState> {
  OnboardingStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingStateHash();

  @$internal
  @override
  OnboardingState create() => OnboardingState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingScreenState>(value),
    );
  }
}

String _$onboardingStateHash() => r'5eccfa2552dfa420debc55f817ec9c73dace6425';

abstract class _$OnboardingState extends $Notifier<OnboardingScreenState> {
  OnboardingScreenState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OnboardingScreenState, OnboardingScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OnboardingScreenState, OnboardingScreenState>,
              OnboardingScreenState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
