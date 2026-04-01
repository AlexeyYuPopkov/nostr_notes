import 'package:nostr_notes/common/domain/error/app_error.dart';

abstract interface class DecryptionRepository {
  const DecryptionRepository();

  Future<String> encrypt({required String plaintext, required String password});

  Future<String> decrypt({
    required String ciphertext,
    required String password,
  });
}

final class DecryptionRepositoryHmacException extends AppError {
  @override
  String get message =>
      'Ошибка проверки HMAC: данные повреждены или пароль неверный!';

  const DecryptionRepositoryHmacException({super.parentError});

  @override
  String toString() => message;
}

final class DecryptionRepositorySomethingWrongException extends AppError {
  @override
  String get message =>
      'Что-то пошло не так при работе с шифрованием/дешифрованием!';

  const DecryptionRepositorySomethingWrongException({super.parentError});

  @override
  String toString() => message;
}
