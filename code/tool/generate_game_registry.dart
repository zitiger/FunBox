import 'dart:io';

const _generatedAssetStart = '# BEGIN GENERATED GAME ASSETS';
const _generatedAssetEnd = '# END GENERATED GAME ASSETS';

void main(List<String> args) async {
  final options = _parseArgs(args);
  final gamesRoot = Directory(options['games-root']!);
  final registryOut = File(options['registry-out']!);
  final pubspecFile = File(options['pubspec']!);

  if (!await gamesRoot.exists()) {
    stderr.writeln('Games root does not exist: ${gamesRoot.path}');
    exitCode = 64;
    return;
  }

  if (!await pubspecFile.exists()) {
    stderr.writeln('Pubspec file does not exist: ${pubspecFile.path}');
    exitCode = 64;
    return;
  }

  final packageRoot = Directory(pubspecFile.parent.path);
  final packageName = _readPackageName(await pubspecFile.readAsString());
  final manifests = await _scanManifests(
    gamesRoot: gamesRoot,
    packageRoot: packageRoot,
  );

  await registryOut.parent.create(recursive: true);
  await registryOut.writeAsString(_buildRegistrySource(packageName, manifests));
  await pubspecFile.writeAsString(
    _replaceGeneratedAssets(await pubspecFile.readAsString(), manifests),
  );
}

Map<String, String> _parseArgs(List<String> args) {
  final values = <String, String>{};
  for (var index = 0; index < args.length; index += 2) {
    final key = args[index];
    if (!key.startsWith('--') || index + 1 >= args.length) {
      throw ArgumentError('Invalid arguments: $args');
    }
    values[key.substring(2)] = args[index + 1];
  }

  for (final requiredKey in ['games-root', 'registry-out', 'pubspec']) {
    if (!values.containsKey(requiredKey)) {
      throw ArgumentError('Missing required --$requiredKey argument.');
    }
  }

  return values;
}

Future<List<_ManifestRecord>> _scanManifests({
  required Directory gamesRoot,
  required Directory packageRoot,
}) async {
  final manifests = <_ManifestRecord>[];

  await for (final entity in gamesRoot.list()) {
    if (entity is! Directory) {
      continue;
    }

    final manifestFile = File(
      '${entity.path}${Platform.pathSeparator}game_manifest.yaml',
    );
    if (!await manifestFile.exists()) {
      continue;
    }

    final yaml = _parseManifest(await manifestFile.readAsString());

    final id = yaml['id']?.toString();
    final title = yaml['title']?.toString();
    final category = yaml['category']?.toString();
    final iconAsset = yaml['iconAsset']?.toString();
    final coverAsset = yaml['coverAsset']?.toString();
    final supportsResume = _parseBool(yaml['supportsResume']);
    final supportedModes = yaml['supportedModes'] as List<String>?;
    final sortOrder = _parseInt(yaml['sortOrder']);
    final enabled = _parseBool(yaml['enabled']);

    if ([
      id,
      title,
      category,
      iconAsset,
      coverAsset,
      supportsResume,
      supportedModes,
      sortOrder,
      enabled,
    ].contains(null)) {
      throw FormatException(
        'Manifest missing required fields: ${manifestFile.path}',
      );
    }

    final manifestId = id!;
    final manifestTitle = title!;
    final manifestCategory = category!;
    final manifestIconAsset = iconAsset!;
    final manifestCoverAsset = coverAsset!;
    final manifestSupportedModes = supportedModes!;
    final manifestSortOrder = sortOrder!;
    final manifestSupportsResume = supportsResume!;
    final manifestEnabled = enabled!;

    _ensureAssetExists(packageRoot, manifestIconAsset);
    _ensureAssetExists(packageRoot, manifestCoverAsset);

    manifests.add(
      _ManifestRecord(
        id: manifestId,
        directoryName: entity.uri.pathSegments.lastWhere(
          (segment) => segment.isNotEmpty,
        ),
        title: manifestTitle,
        category: manifestCategory,
        iconAsset: manifestIconAsset,
        coverAsset: manifestCoverAsset,
        supportsResume: manifestSupportsResume,
        supportedModes: manifestSupportedModes,
        sortOrder: manifestSortOrder,
        enabled: manifestEnabled,
        assetDeclarations: _buildAssetDeclarations(entity),
      ),
    );
  }

  manifests.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return manifests;
}

Map<String, Object?> _parseManifest(String content) {
  final data = <String, Object?>{};
  String? currentListKey;
  final currentList = <String>[];

  for (final rawLine in content.split(RegExp(r'\r?\n'))) {
    final line = rawLine.trimRight();
    if (line.trim().isEmpty || line.trimLeft().startsWith('#')) {
      continue;
    }

    final trimmed = line.trimLeft();
    if (trimmed.startsWith('- ')) {
      if (currentListKey == null) {
        throw FormatException('List item found before list key.');
      }
      currentList.add(trimmed.substring(2).trim());
      continue;
    }

    if (currentListKey != null) {
      data[currentListKey] = List<String>.unmodifiable(currentList.toList());
      currentListKey = null;
      currentList.clear();
    }

    final separator = trimmed.indexOf(':');
    if (separator == -1) {
      throw FormatException('Invalid manifest line: $trimmed');
    }

    final key = trimmed.substring(0, separator).trim();
    final value = trimmed.substring(separator + 1).trim();
    if (value.isEmpty) {
      currentListKey = key;
      continue;
    }

    data[key] = value;
  }

  if (currentListKey != null) {
    data[currentListKey] = List<String>.unmodifiable(currentList.toList());
  }

  return data;
}

bool? _parseBool(Object? value) {
  final normalized = value?.toString().trim().toLowerCase();
  switch (normalized) {
    case 'true':
      return true;
    case 'false':
      return false;
    default:
      return null;
  }
}

int? _parseInt(Object? value) => int.tryParse(value?.toString() ?? '');

void _ensureAssetExists(Directory packageRoot, String assetPath) {
  final file = File(
    '${packageRoot.path}${Platform.pathSeparator}${assetPath.replaceAll('/', Platform.pathSeparator)}',
  );
  if (!file.existsSync()) {
    throw FileSystemException('Manifest asset does not exist', file.path);
  }
}

String _readPackageName(String pubspecContent) {
  final match = RegExp(
    r'^name:\s*(.+)$',
    multiLine: true,
  ).firstMatch(pubspecContent);
  if (match == null) {
    throw FormatException('Unable to determine package name from pubspec.');
  }

  return match.group(1)!.trim();
}

String _replaceGeneratedAssets(
  String content,
  List<_ManifestRecord> manifests,
) {
  final start = content.indexOf(_generatedAssetStart);
  final end = content.indexOf(_generatedAssetEnd);
  if (start == -1 || end == -1 || end < start) {
    throw FormatException('Pubspec is missing generated asset markers.');
  }

  final generatedLines = manifests
      .expand((manifest) => manifest.assetDeclarations)
      .map((assetPath) => '    - $assetPath')
      .join('\n');

  return '${content.substring(0, start)}$_generatedAssetStart\n$generatedLines\n    $_generatedAssetEnd${content.substring(end + _generatedAssetEnd.length)}';
}

List<String> _buildAssetDeclarations(Directory gameDirectory) {
  final assetsRoot = Directory(
    '${gameDirectory.path}${Platform.pathSeparator}assets',
  );
  if (!assetsRoot.existsSync()) {
    return const [];
  }

  final gameDirectoryName = gameDirectory.uri.pathSegments.lastWhere(
    (segment) => segment.isNotEmpty,
  );
  final basePath = 'games/$gameDirectoryName/assets';
  final declarations = <String>[];

  for (final entity in assetsRoot.listSync()) {
    if (entity is Directory) {
      final name = entity.uri.pathSegments.lastWhere((segment) => segment.isNotEmpty);
      declarations.add('$basePath/$name/');
    } else if (entity is File) {
      final name = entity.uri.pathSegments.last;
      declarations.add('$basePath/$name');
    }
  }

  declarations.sort();
  return declarations;
}

String _buildRegistrySource(
  String packageName,
  List<_ManifestRecord> manifests,
) {
  final buffer = StringBuffer()
    ..writeln(
      "import 'package:$packageName/src/platform/games/game_manifest.dart';",
    )
    ..writeln(
      "import 'package:$packageName/src/platform/games/game_module.dart';",
    )
    ..writeln(
      "import 'package:$packageName/src/platform/games/static_game_module.dart';",
    )
    ..writeln()
    ..writeln('final List<GameModule> generatedGameModules = [');

  for (final manifest in manifests) {
    final modes = manifest.supportedModes
        .map((mode) => "'${_escape(mode)}'")
        .join(', ');
    buffer
      ..writeln('  const StaticGameModule(')
      ..writeln('    manifest: GameManifest(')
      ..writeln("      id: '${_escape(manifest.id)}',")
      ..writeln("      title: '${_escape(manifest.title)}',")
      ..writeln("      category: '${_escape(manifest.category)}',")
      ..writeln("      iconAsset: '${_escape(manifest.iconAsset)}',")
      ..writeln("      coverAsset: '${_escape(manifest.coverAsset)}',")
      ..writeln('      supportsResume: ${manifest.supportsResume},')
      ..writeln('      supportedModes: [$modes],')
      ..writeln('      sortOrder: ${manifest.sortOrder},')
      ..writeln('      enabled: ${manifest.enabled},')
      ..writeln('    ),')
      ..writeln('  ),');
  }

  buffer.writeln('];');
  return buffer.toString();
}

String _escape(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

class _ManifestRecord {
  const _ManifestRecord({
    required this.id,
    required this.directoryName,
    required this.title,
    required this.category,
    required this.iconAsset,
    required this.coverAsset,
    required this.supportsResume,
    required this.supportedModes,
    required this.sortOrder,
    required this.enabled,
    required this.assetDeclarations,
  });

  final String id;
  final String directoryName;
  final String title;
  final String category;
  final String iconAsset;
  final String coverAsset;
  final bool supportsResume;
  final List<String> supportedModes;
  final int sortOrder;
  final bool enabled;
  final List<String> assetDeclarations;
}
