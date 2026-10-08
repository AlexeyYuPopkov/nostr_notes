import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tools/fakes/fake_backup_files.dart';

final _bech32Nsec = RegExp(r'nsec1[02-9ac-hj-np-z]{58}');

/// Usage: a key backup zip was shared
Future<void> aKeyBackupZipWasShared(WidgetTester tester) async {
  final shared = fakeFileShare.shared;
  expect(shared, hasLength(1));
  expect(shared.single.fileName, endsWith('.zip'));

  final archive = ZipDecoder().decodeBytes(shared.single.bytes);
  expect(archive.files.map((file) => file.name), anyElement(endsWith('.py')));

  final leaksPlainKey = archive.files.any(
    (file) => _bech32Nsec.hasMatch(
      utf8.decode(file.content as List<int>, allowMalformed: true),
    ),
  );
  expect(leaksPlainKey, isFalse, reason: 'the key must be stored encrypted');
}
