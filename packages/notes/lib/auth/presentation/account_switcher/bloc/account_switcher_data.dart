import 'package:equatable/equatable.dart';

final class AccountSwitcherData extends Equatable {
  final String currentUserPubkey;
  final List<String> accounts;

  const AccountSwitcherData._({
    required this.currentUserPubkey,
    required this.accounts,
  });

  factory AccountSwitcherData.initial() {
    return const AccountSwitcherData._(currentUserPubkey: '', accounts: []);
  }

  @override
  List<Object?> get props => [currentUserPubkey, accounts];

  AccountSwitcherData copyWith({
    String? currentUserPubkey,
    List<String>? accounts,
  }) {
    return AccountSwitcherData._(
      currentUserPubkey: currentUserPubkey ?? this.currentUserPubkey,
      accounts: accounts ?? this.accounts,
    );
  }
}
