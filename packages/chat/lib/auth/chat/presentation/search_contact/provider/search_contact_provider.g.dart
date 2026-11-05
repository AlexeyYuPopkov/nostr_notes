// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_contact_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchContactProvider)
final searchContactProviderProvider = SearchContactProviderProvider._();

final class SearchContactProviderProvider
    extends $NotifierProvider<SearchContactProvider, SearchContactState> {
  SearchContactProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchContactProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchContactProviderHash();

  @$internal
  @override
  SearchContactProvider create() => SearchContactProvider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchContactState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchContactState>(value),
    );
  }
}

String _$searchContactProviderHash() =>
    r'f3e3323831a2081599a7c1ad6962d5391eb8c851';

abstract class _$SearchContactProvider extends $Notifier<SearchContactState> {
  SearchContactState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SearchContactState, SearchContactState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchContactState, SearchContactState>,
              SearchContactState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
