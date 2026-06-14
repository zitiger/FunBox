import 'dart:io';

const _generatedDepsStart = '# BEGIN GENERATED GAME PACKAGE DEPS';
const _generatedDepsEnd = '# END GENERATED GAME PACKAGE DEPS';

void main(List<String> args) async {
  final options = _parseArgs(args);
  final packagesRoot = Directory(
    options['packages-root'] ?? options['games-root']!,
  );
  final registryOut = File(options['registry-out']!);
  final pubspecFile = File(options['pubspec']!);

  if (!await packagesRoot.exists()) {
    stderr.writeln('Packages root does not exist: ${packagesRoot.path}');
    exitCode = 64;
    return;
  }

  if (!await pubspecFile.exists()) {
    stderr.writeln('Pubspec file does not exist: ${pubspecFile.path}');
    exitCode = 64;
    return;
  }

  final appPackageName = _readPackageName(await pubspecFile.readAsString());
  final appRoot = Directory(pubspecFile.parent.path);
  final packages = await _scanPackages(packagesRoot: packagesRoot);

  await registryOut.parent.create(recursive: true);
  await registryOut.writeAsString(
    _buildRegistrySource(appPackageName, packages),
  );
  await pubspecFile.writeAsString(
    _replaceGeneratedPackageDeps(
      await pubspecFile.readAsString(),
      appRoot: appRoot,
      packages: packages,
    ),
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

  final hasPackagesRoot = values.containsKey('packages-root');
  final hasGamesRoot = values.containsKey('games-root');
  if (!hasPackagesRoot && !hasGamesRoot) {
    throw ArgumentError('Missing required --packages-root argument.');
  }

  for (final requiredKey in ['registry-out', 'pubspec']) {
    if (!values.containsKey(requiredKey)) {
      throw ArgumentError('Missing required --$requiredKey argument.');
    }
  }

  return values;
}

Future<List<_PackageRecord>> _scanPackages({
  required Directory packagesRoot,
}) async {
  final records = <_PackageRecord>[];

  await for (final entity in packagesRoot.list()) {
    if (entity is! Directory) {
      continue;
    }

    final packagePubspec = File(
      '${entity.path}${Platform.pathSeparator}pubspec.yaml',
    );
    final manifestFile = File(
      '${entity.path}${Platform.pathSeparator}game_manifest.yaml',
    );

    if (!await packagePubspec.exists() || !await manifestFile.exists()) {
      continue;
    }

    final pubspecContent = await packagePubspec.readAsString();
    final packageName = _readPackageName(pubspecContent);
    if (packageName == 'funbox_game_api') {
      continue;
    }

    final yaml = _parseManifest(await manifestFile.readAsString());
    final id = yaml['id']?.toString();
    final title = yaml['title']?.toString();
    final category = yaml['category']?.toString();
    final manifestPackageName = yaml['packageName']?.toString();
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
      manifestPackageName,
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

    if (manifestPackageName != packageName) {
      throw FormatException(
        'Manifest packageName does not match pubspec name: ${manifestFile.path}',
      );
    }

    _ensurePackageAssetExists(entity, iconAsset!);
    _ensurePackageAssetExists(entity, coverAsset!);

    records.add(
      _PackageRecord(
        id: id!,
        title: title!,
        category: category!,
        directoryName: entity.uri.pathSegments.lastWhere(
          (segment) => segment.isNotEmpty,
        ),
        packageName: packageName,
        iconAsset: iconAsset,
        coverAsset: coverAsset,
        supportsResume: supportsResume!,
        supportedModes: supportedModes!,
        sortOrder: sortOrder!,
        enabled: enabled!,
        packageRoot: entity,
        hasModuleEntry: File(
          '${entity.path}${Platform.pathSeparator}lib${Platform.pathSeparator}game_module.dart',
        ).existsSync(),
      ),
    );
  }

  records.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return records;
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

void _ensurePackageAssetExists(Directory packageRoot, String assetPath) {
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

String _replaceGeneratedPackageDeps(
  String content, {
  required Directory appRoot,
  required List<_PackageRecord> packages,
}) {
  final start = content.indexOf(_generatedDepsStart);
  final end = content.indexOf(_generatedDepsEnd);
  if (start == -1 || end == -1 || end < start) {
    throw FormatException('Pubspec is missing generated dependency markers.');
  }

  final generatedLines = packages
      .map((package) {
        final relativePath = _relativePath(appRoot, package.packageRoot);
        return '  ${package.packageName}:\n    path: $relativePath';
      })
      .join('\n');

  return '${content.substring(0, start)}$_generatedDepsStart\n$generatedLines\n  $_generatedDepsEnd${content.substring(end + _generatedDepsEnd.length)}';
}

String _relativePath(Directory from, Directory to) {
  final fromParts =
      Uri.directory(from.absolute.path, windows: Platform.isWindows)
          .normalizePath()
          .pathSegments
          .where((segment) => segment.isNotEmpty)
          .toList();
  final toParts = Uri.directory(to.absolute.path, windows: Platform.isWindows)
      .normalizePath()
      .pathSegments
      .where((segment) => segment.isNotEmpty)
      .toList();
  var commonLength = 0;

  while (commonLength < fromParts.length &&
      commonLength < toParts.length &&
      fromParts[commonLength].toLowerCase() ==
          toParts[commonLength].toLowerCase()) {
    commonLength += 1;
  }

  final buffer = <String>[
    for (var i = commonLength; i < fromParts.length; i += 1) '..',
    ...toParts.skip(commonLength),
  ];

  return buffer.join('/');
}

String _buildRegistrySource(
  String appPackageName,
  List<_PackageRecord> packages,
) {
  final moduleImports = packages
      .where((package) => package.hasModuleEntry)
      .map(
        (package) =>
            "import 'package:${package.packageName}/game_module.dart' as ${_moduleAlias(package.id)};",
      )
      .join('\n');

  final buffer = StringBuffer()
    ..writeln(
      "import 'package:$appPackageName/src/platform/games/game_manifest.dart';",
    )
    ..writeln(
      "import 'package:$appPackageName/src/platform/games/game_module.dart';",
    )
    ..writeln(
      "import 'package:$appPackageName/src/platform/games/static_game_module.dart';",
    );

  if (moduleImports.isNotEmpty) {
    buffer.writeln(moduleImports);
  }

  buffer
    ..writeln()
    ..writeln('final List<GameModule> generatedGameModules = [');

  for (final package in packages) {
    final modes = package.supportedModes
        .map((mode) => "'${_escape(mode)}'")
        .join(', ');
    final manifestSource = StringBuffer()
      ..writeln('    GameManifest(')
      ..writeln("      id: '${_escape(package.id)}',")
      ..writeln("      title: '${_escape(package.title)}',")
      ..writeln("      category: '${_escape(package.category)}',")
      ..writeln("      packageName: '${_escape(package.packageName)}',")
      ..writeln("      iconAsset: '${_escape(package.iconAsset)}',")
      ..writeln("      coverAsset: '${_escape(package.coverAsset)}',")
      ..writeln('      supportsResume: ${package.supportsResume},')
      ..writeln('      supportedModes: [$modes],')
      ..writeln('      sortOrder: ${package.sortOrder},')
      ..writeln('      enabled: ${package.enabled},')
      ..write('    )');

    if (package.hasModuleEntry) {
      buffer
        ..writeln('  ${_moduleAlias(package.id)}.createGameModule(')
        ..writeln('    const ${manifestSource.toString().trimLeft()}')
        ..writeln('  ),');
    } else {
      buffer
        ..writeln('  const StaticGameModule(')
        ..writeln('    manifest: ')
        ..writeln(manifestSource.toString())
        ..writeln('  ),');
    }
  }

  buffer.writeln('];');
  return buffer.toString();
}

String _escape(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

String _moduleAlias(String id) {
  final normalized = id.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
  if (normalized.isEmpty) {
    return 'game_module';
  }
  if (RegExp(r'^[0-9]').hasMatch(normalized)) {
    return 'game_${normalized}_module';
  }
  return '${normalized}_module';
}

class _PackageRecord {
  const _PackageRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.directoryName,
    required this.packageName,
    required this.iconAsset,
    required this.coverAsset,
    required this.supportsResume,
    required this.supportedModes,
    required this.sortOrder,
    required this.enabled,
    required this.packageRoot,
    required this.hasModuleEntry,
  });

  final String id;
  final String title;
  final String category;
  final String directoryName;
  final String packageName;
  final String iconAsset;
  final String coverAsset;
  final bool supportsResume;
  final List<String> supportedModes;
  final int sortOrder;
  final bool enabled;
  final Directory packageRoot;
  final bool hasModuleEntry;
}
