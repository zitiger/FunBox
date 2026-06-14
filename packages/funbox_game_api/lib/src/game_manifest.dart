class GameManifest {
  const GameManifest({
    required this.id,
    required this.title,
    required this.category,
    required this.packageName,
    required this.iconAsset,
    required this.coverAsset,
    required this.supportsResume,
    required this.supportedModes,
    required this.sortOrder,
    required this.enabled,
  });

  final String id;
  final String title;
  final String category;
  final String packageName;
  final String iconAsset;
  final String coverAsset;
  final bool supportsResume;
  final List<String> supportedModes;
  final int sortOrder;
  final bool enabled;
}
