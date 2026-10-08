import 'package:equatable/equatable.dart';

final class KeyBackupEntry extends Equatable {
  final String nsec;

  /// User-facing account name, if the account has one.
  final String? label;

  const KeyBackupEntry({required this.nsec, this.label});

  @override
  List<Object?> get props => [nsec, label];
}
