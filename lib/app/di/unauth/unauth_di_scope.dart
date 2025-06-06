import 'package:di_storage/di_storage.dart';
import 'package:nostr_notes/unauth/data/validators/nsec_validator_impl.dart';
import 'package:nostr_notes/unauth/domain/validators/nsec_validator.dart';

final class UnauthDiScope extends DiScope {
  const UnauthDiScope();

  @override
  void bind(DiStorage di) {
    di.bind<NsecValidator>(
      () => const NsecValidatorImpl(),
      module: this,
      lifeTime: const LifeTime.single(),
    );
  }
}
