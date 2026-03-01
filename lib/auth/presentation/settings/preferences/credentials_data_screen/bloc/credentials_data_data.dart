import 'package:equatable/equatable.dart';

final class CredentialsDataData extends Equatable {
  final String nsec;
  final String pubkey;
  final String privateKey;
  final String pin;

  const CredentialsDataData._({
    required this.nsec,
    required this.pubkey,
    required this.privateKey,
    required this.pin,
  });

  factory CredentialsDataData.initial() {
    return const CredentialsDataData._(
      nsec: '',
      pubkey: '',
      privateKey: '',
      pin: '',
    );
  }

  @override
  List<Object?> get props => [nsec, pubkey, privateKey, pin];

  CredentialsDataData copyWith({
    String? nsec,
    String? pubkey,
    String? privateKey,
    String? pin,
  }) {
    return CredentialsDataData._(
      nsec: nsec ?? this.nsec,
      pubkey: pubkey ?? this.pubkey,
      privateKey: privateKey ?? this.privateKey,
      pin: pin ?? this.pin,
    );
  }
}
