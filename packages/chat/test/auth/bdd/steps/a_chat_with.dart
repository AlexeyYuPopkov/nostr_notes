import 'package:chat/common/data/fake_chats_repo.dart';
import 'package:chat/common/domain/repo/chats_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// Usage: And a chat with {'alice-pubkey'}
Future<void> aChatWith(WidgetTester tester, String pubkey) async {
  GetIt.I.unregister<ChatsRepo>();
  GetIt.I.registerSingleton<ChatsRepo>(FakeChatsRepo(pubkeys: [pubkey]));
}
