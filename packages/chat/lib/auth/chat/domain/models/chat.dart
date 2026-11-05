import 'package:equatable/equatable.dart';

final class Chat extends Equatable {
  final String pubkey;

  const Chat({required this.pubkey});

  @override
  List<Object?> get props => [pubkey];
}
