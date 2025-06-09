import 'package:di_storage/di_storage.dart';

abstract interface class ErrorMessagesProvider {
  static ErrorMessagesProvider? _default;
  static ErrorMessagesProvider get defaultProvider =>
      _default ??= DiStorage.shared.resolve<ErrorMessagesProvider>();

  const ErrorMessagesProvider._();

  String get commonError;
  String get authError;
  String get emptyNsec;
  String get invalidNsecFormat;
  String get emptyPubkey;
  String get emptyPin;
  String errorInvalidPinFormatMinCount(int minCount);
}
