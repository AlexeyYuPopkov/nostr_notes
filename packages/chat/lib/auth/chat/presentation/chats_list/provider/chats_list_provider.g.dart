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
          AsyncValue<List<Chat>>,
          List<Chat>,
          FutureOr<List<Chat>>
        >
    with $FutureModifier<List<Chat>>, $FutureProvider<List<Chat>> {
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
  $FutureProviderElement<List<Chat>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Chat>> create(Ref ref) {
    return chatsList(ref);
  }
}

String _$chatsListHash() => r'9a5592f23e49dceb6abfd5535f1559da9caf8110';
