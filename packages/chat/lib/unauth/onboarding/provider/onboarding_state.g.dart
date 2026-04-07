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
    extends $NotifierProvider<OnboardingState, List<OnboardingStep>> {
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
  Override overrideWithValue(List<OnboardingStep> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<OnboardingStep>>(value),
    );
  }
}

String _$onboardingStateHash() => r'eab70ffc575e8902d04b4655e0be59b89696eeff';

abstract class _$OnboardingState extends $Notifier<List<OnboardingStep>> {
  List<OnboardingStep> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<OnboardingStep>, List<OnboardingStep>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<OnboardingStep>, List<OnboardingStep>>,
              List<OnboardingStep>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
