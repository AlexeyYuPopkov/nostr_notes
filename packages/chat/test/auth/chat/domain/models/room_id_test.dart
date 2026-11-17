import 'package:chat/auth/chat/domain/models/room_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('both sides of a conversation share the room', () {
    expect(RoomId.of('alice', 'bob'), RoomId.of('bob', 'alice'));
  });

  test('different pairs get different rooms', () {
    expect(RoomId.of('alice', 'bob'), isNot(RoomId.of('alice', 'carol')));
  });

  test('a note to self is a room of its own', () {
    expect(RoomId.of('alice', 'alice').value, 'alice:alice');
  });
}
