// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatProvider)
final chatProviderProvider = ChatProviderFamily._();

final class ChatProviderProvider
    extends $NotifierProvider<ChatProvider, ChatState> {
  ChatProviderProvider._({
    required ChatProviderFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chatProviderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatProviderHash();

  @override
  String toString() {
    return r'chatProviderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatProvider create() => ChatProvider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatProviderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatProviderHash() => r'b207edb69941d8ec9e4a1a62c81bd7ab01ad7a8a';

final class ChatProviderFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatProvider,
          ChatState,
          ChatState,
          ChatState,
          String
        > {
  ChatProviderFamily._()
    : super(
        retry: null,
        name: r'chatProviderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatProviderProvider call(String peerPubkey) =>
      ChatProviderProvider._(argument: peerPubkey, from: this);

  @override
  String toString() => r'chatProviderProvider';
}

abstract class _$ChatProvider extends $Notifier<ChatState> {
  late final _$args = ref.$arg as String;
  String get peerPubkey => _$args;

  ChatState build(String peerPubkey);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ChatState, ChatState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatState, ChatState>,
              ChatState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
