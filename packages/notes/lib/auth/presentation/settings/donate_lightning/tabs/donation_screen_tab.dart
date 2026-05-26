import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import 'donation_screen_amount_tab.dart';
import 'donation_screen_pay_tab.dart';

sealed class DonationScreenTab extends Equatable {
  static List<DonationScreenTab> get tabs => const [AmountTab(), PayTab()];
  const DonationScreenTab();

  int getIndex();

  Widget build(BuildContext context);

  const factory DonationScreenTab.amount() = AmountTab;
  const factory DonationScreenTab.pay() = PayTab;
}

final class AmountTab extends DonationScreenTab {
  const AmountTab();

  @override
  int getIndex() => 0;

  @override
  List<Object?> get props => [];

  @override
  Widget build(BuildContext context) {
    return const DonationScreenAmountTab();
  }
}

final class PayTab extends DonationScreenTab {
  const PayTab();

  @override
  int getIndex() => 1;
  @override
  List<Object?> get props => [];

  @override
  Widget build(BuildContext context) {
    return const DonationScreenPayTab();
  }
}
