import 'package:chat/auth/chat/domain/usecase/get_contact_usecase.dart';
import 'package:common/domain/model/user.dart';

import 'contact_profiles.dart';

final class GetContactUsecaseImpl implements GetContactUsecase {
  final ContactProfiles _profiles;

  const GetContactUsecaseImpl({required this._profiles});

  @override
  Stream<User> execute(String pubkey) {
    return _profiles.watch({pubkey}).map((profiles) => profiles[pubkey]!);
  }
}
