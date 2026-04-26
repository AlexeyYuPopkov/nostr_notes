import 'package:common/domain/repo/get_classification_repo.dart';
import 'package:common/services/event_store/database/daos/note_class_probabilities_dao.dart';
import 'package:di_storage/di_storage.dart';
import 'package:nostr_notes/auth/data/ai/classification_repo_impl.dart';
import 'package:nostr_notes/auth/domain/usecase/calculate_classification_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_classification_usecase.dart';

final class ClassificationDi extends DiScope {
  const ClassificationDi();

  @override
  void bind(DiStorage di) {
    di.bind<GetClassificationRepo>(
      () => NoteClassProbabilitiesDao(di.resolve()),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    di.bind<CalculateClassificationUsecase>(
      () => CalculateClassificationUsecase(
        classificationRepo: ClassificationRepoImpl(),
        getClassificationRepo: di.resolve(),
        getClassificationUsecase: di.resolve(),
      ),
      module: this,
      lifeTime: const LifeTime.single(),
    );

    di.bind<GetClassificationUsecase>(
      () => GetClassificationUsecase(getClassificationRepo: di.resolve()),
      module: this,
      lifeTime: const LifeTime.single(),
    );
  }
}
