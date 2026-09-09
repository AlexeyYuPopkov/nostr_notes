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
    r'db1e5335bbcb49384c097266606b7bdd9d405b1c';

abstract class _$OnboardingRelaysProvider
    extends $Notifier<OnboardingRelaysState> {
  OnboardingRelaysState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<OnboardingRelaysState, OnboardingRelaysState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OnboardingRelaysState, OnboardingRelaysState>,
              OnboardingRelaysState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
