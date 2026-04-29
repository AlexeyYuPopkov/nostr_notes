import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nostr_notes/auth/domain/repo/classification_repo.dart';

import 'classification_datasource.dart';

final class ClassificationRepoImpl implements ClassificationRepo {
  @override
  Future<Map<String, double>> classify(String text) async {
    const path = 'assets/ai/classification_model.bin';
    final byteData = await rootBundle.load(path);
    final bytes = byteData.buffer.asUint8List();
    return compute(_classify, (bytes, text));
  }

  static Map<String, double> _classify((Uint8List, String) args) {
    final (bytes, text) = args;
    final classificator = ClassificationDatasource.fromBytes(bytes);
    return classificator.classify(text);
  }

  // 0 =
  // "finance" -> 2.8035212990610117e-9
  // 1 =
  // "journal" -> 1.7984787859089538e-12
  // 2 =
  // "personal" -> 1.4674909225885353e-8
  // 3 =
  // "security" -> 0.5
  // 4 =
  // "travel" -> 0.212436087830069
  // 5 =
  // "work" -> 0.4821769502239718
}
