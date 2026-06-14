import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'generator scans manifests and writes registry plus pubspec asset block',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'funbox_registry_test_',
      );
      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final gamesDir = Directory(
        '${tempRoot.path}${Platform.pathSeparator}games',
      );
      await gamesDir.create(recursive: true);

      await _createGame(
        gamesDir,
        id: 'gomoku',
        title: '五子棋',
        category: 'board',
      );
      await _createGame(
        gamesDir,
        id: 'snake',
        title: '贪吃蛇',
        category: 'casual',
      );

      final generatedDir = Directory(
        '${tempRoot.path}${Platform.pathSeparator}lib${Platform.pathSeparator}src${Platform.pathSeparator}generated',
      );
      await generatedDir.create(recursive: true);

      final pubspecFile = File(
        '${tempRoot.path}${Platform.pathSeparator}pubspec.yaml',
      );
      await pubspecFile.writeAsString('''
name: temp_code
flutter:
  assets:
    - assets/images/home/
    # BEGIN GENERATED GAME ASSETS
    # END GENERATED GAME ASSETS
''');

      final result = await Process.run('D:\\flutter\\bin\\cache\\dart-sdk\\bin\\dart.exe', [
        '${Directory.current.path}${Platform.pathSeparator}tool${Platform.pathSeparator}generate_game_registry.dart',
        '--games-root',
        gamesDir.path,
        '--registry-out',
        '${generatedDir.path}${Platform.pathSeparator}game_registry.g.dart',
        '--pubspec',
        pubspecFile.path,
      ], workingDirectory: Directory.current.path);

      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');

      final registryFile = File(
        '${generatedDir.path}${Platform.pathSeparator}game_registry.g.dart',
      );
      expect(await registryFile.exists(), isTrue);

      final registryContent = await registryFile.readAsString();
      expect(registryContent, contains('gomoku'));
      expect(registryContent, contains('snake'));
      expect(registryContent, contains('五子棋'));
      expect(registryContent, contains('贪吃蛇'));

      final pubspecContent = await pubspecFile.readAsString();
      expect(pubspecContent, contains('- games/gomoku/assets/images/'));
      expect(pubspecContent, contains('- games/snake/assets/images/'));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

Future<void> _createGame(
  Directory gamesDir, {
  required String id,
  required String title,
  required String category,
}) async {
  final root = Directory('${gamesDir.path}${Platform.pathSeparator}$id');
  final assetsDir = Directory(
    '${root.path}${Platform.pathSeparator}assets${Platform.pathSeparator}images',
  );
  await assetsDir.create(recursive: true);

  await File(
    '${assetsDir.path}${Platform.pathSeparator}icon.png',
  ).writeAsBytes([0, 1, 2, 3]);

  await File(
    '${root.path}${Platform.pathSeparator}game_manifest.yaml',
  ).writeAsString('''
id: $id
title: $title
category: $category
iconAsset: games/$id/assets/images/icon.png
coverAsset: games/$id/assets/images/icon.png
supportsResume: true
supportedModes:
  - classic
sortOrder: 10
enabled: true
''');
}
