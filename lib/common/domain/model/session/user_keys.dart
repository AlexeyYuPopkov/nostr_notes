import 'package:equatable/equatable.dart';

final class UserKeys extends Equatable {
  final String publicKey;
  final String privateKey;

  const UserKeys({required this.publicKey, required this.privateKey});

  @override
  List<Object?> get props => [publicKey, privateKey];
}
