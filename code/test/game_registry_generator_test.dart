import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'generator scans local packages and writes dependency block plus registry',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'funbox_registry_test_',
      );
      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final packagesDir = Directory(
        '${tempRoot.path}${Platform.pathSeparator}packages',
      );
      await packagesDir.create(recursive: true);

      await _createPackage(
        packagesDir,
        id: 'gomoku',
        title: 'Gomoku',
        category: 'board',
        packageName: 'game_gomoku',
        withModuleEntry: true,
      );
      await _createPackage(
        packagesDir,
        id: 'snake',
        title: 'Snake',
        category: 'casual',
        packageName: 'game_snake',
      );

      final generatedDir = Directory(
        '${tempRoot.path}${Platform.pathSeparator}code${Platform.pathSeparator}lib${Platform.pathSeparator}src${Platform.pathSeparator}generated',
      );
      await generatedDir.create(recursive: true);

      final appDir = Directory('${tempRoot.path}${Platform.pathSeparator}code');
      await appDir.create(recursive: true);

      final pubspecFile = File(
        '${appDir.path}${Platform.pathSeparator}pubspec.yaml',
      );
      await pubspecFile.writeAsString('''
name: temp_code
dependencies:
  flutter:
    sdk: flutter
  # BEGIN GENERATED GAME PACKAGE DEPS
  # END GENERATED GAME PACKAGE DEPS
flutter:
  assets:
    - assets/images/home/
''');

      final result = await Process.run(
        'D:\\flutter\\bin\\cache\\dart-sdk\\bin\\dart.exe',
        [
          '${Directory.current.path}${Platform.pathSeparator}tool${Platform.pathSeparator}generate_game_registry.dart',
          '--packages-root',
          packagesDir.path,
          '--registry-out',
          '${generatedDir.path}${Platform.pathSeparator}game_registry.g.dart',
          '--pubspec',
          pubspecFile.path,
        ],
        workingDirectory: Directory.current.path,
      );

      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');

      final registryFile = File(
        '${generatedDir.path}${Platform.pathSeparator}game_registry.g.dart',
      );
      expect(await registryFile.exists(), isTrue);

      final registryContent = await registryFile.readAsString();
      expect(
        registryContent,
        contains("import 'package:game_gomoku/game_module.dart'"),
      );
      expect(registryContent, contains('gomoku_module.createGameModule('));
      expect(registryContent, contains("packageName: 'game_gomoku'"));
      expect(registryContent, contains("packageName: 'game_snake'"));
      expect(registryContent, isNot(contains('generated/game_modules')));

      final pubspecContent = await pubspecFile.readAsString();
      expect(pubspecContent, contains('game_gomoku:'));
      expect(pubspecContent, contains('path: ../packages/game_gomoku'));
      expect(pubspecContent, contains('game_snake:'));
      expect(pubspecContent, contains('path: ../packages/game_snake'));

      final mirroredModulesDir = Directory(
        '${generatedDir.path}${Platform.pathSeparator}game_modules',
      );
      expect(await mirroredModulesDir.exists(), isFalse);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

Future<void> _createPackage(
  Directory packagesDir, {
  required String id,
  required String title,
  required String category,
  required String packageName,
  bool withModuleEntry = false,
}) async {
  final root = Directory(
    '${packagesDir.path}${Platform.pathSeparator}$packageName',
  );
  final assetsDir = Directory(
    '${root.path}${Platform.pathSeparator}assets${Platform.pathSeparator}images',
  );
  await assetsDir.create(recursive: true);

  await File(
    '${assetsDir.path}${Platform.pathSeparator}icon.png',
  ).writeAsBytes([0, 1, 2, 3]);

  await File('${root.path}${Platform.pathSeparator}pubspec.yaml').writeAsString(
    '''
name: $packageName
dependencies:
  flutter:
    sdk: flutter
''',
  );

  await File(
    '${root.path}${Platform.pathSeparator}game_manifest.yaml',
  ).writeAsString('''
id: $id
title: $title
category: $category
packageName: $packageName
iconAsset: assets/images/icon.png
coverAsset: assets/images/icon.png
supportsResume: true
supportedModes:
  - classic
sortOrder: 10
enabled: true
''');

  if (withModuleEntry) {
    final libDir = Directory('${root.path}${Platform.pathSeparator}lib');
    await libDir.create(recursive: true);
    await File(
      '${libDir.path}${Platform.pathSeparator}game_module.dart',
    ).writeAsString('''
Object createGameModule(Object manifest) => Object();
''');
  }
}
