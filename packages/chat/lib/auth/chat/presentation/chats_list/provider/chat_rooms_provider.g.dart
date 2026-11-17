// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_rooms_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The rooms, plus a live relay subscription to the peers' profiles while
/// the list is open. Cells read the profiles from the store themselves.

@ProviderFor(ChatRoomsProvider)
final chatRoomsProviderProvider = ChatRoomsProviderProvider._();

/// The rooms, plus a live relay subscription to the peers' profiles while
/// the list is open. Cells read the profiles from the store themselves.
final class ChatRoomsProviderProvider
    extends $NotifierProvider<ChatRoomsProvider, ChatRoomsState> {
  /// The rooms, plus a live relay subscription to the peers' profiles while
  /// the list is open. Cells read the profiles from the store themselves.
  ChatRoomsProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatRoomsProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatRoomsProviderHash();

  @$internal
  @override
  ChatRoomsProvider create() => ChatRoomsProvider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatRoomsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatRoomsState>(value),
    );
  }
}

String _$chatRoomsProviderHash() => r'921af3f96099138f86171df4addd63c1aad2d2c3';

/// The rooms, plus a live relay subscription to the peers' profiles while
/// the list is open. Cells read the profiles from the store themselves.

abstract class _$ChatRoomsProvider extends $Notifier<ChatRoomsState> {
  ChatRoomsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ChatRoomsState, ChatRoomsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatRoomsState, ChatRoomsState>,
              ChatRoomsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
