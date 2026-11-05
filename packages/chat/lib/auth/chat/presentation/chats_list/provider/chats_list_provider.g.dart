// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chats_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chatsList)
final chatsListProvider = ChatsListProvider._();

final class ChatsListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ChatRoom>>,
          List<ChatRoom>,
          Stream<List<ChatRoom>>
        >
    with $FutureModifier<List<ChatRoom>>, $StreamProvider<List<ChatRoom>> {
  ChatsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatsListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatsListHash();

  @$internal
  @override
  $StreamProviderElement<List<ChatRoom>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ChatRoom>> create(Ref ref) {
    return chatsList(ref);
  }
}

String _$chatsListHash() => r'ddbbe93ad08e6e643799230f02b37f6c3331bb64';
