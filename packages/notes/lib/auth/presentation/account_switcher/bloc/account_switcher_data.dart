import 'package:equatable/equatable.dart';

final class AccountSwitcherData extends Equatable {
  final String currentUserPubkey;

  const AccountSwitcherData._({required this.currentUserPubkey});

  factory AccountSwitcherData.initial() {
    return const AccountSwitcherData._(currentUserPubkey: '');
  }

  @override
  List<Object?> get props => [currentUserPubkey];

  AccountSwitcherData copyWith({String? currentUserPubkey}) {
    return AccountSwitcherData._(
      currentUserPubkey: currentUserPubkey ?? this.currentUserPubkey,
    );
  }
}
