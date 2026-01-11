class DataAsset {
  final String path;
  final String rootKey;
  const DataAsset(this.path, this.rootKey);
}

class AppAssets {
  static const DataAsset concepts = DataAsset(
    'assets/data/concepts.json',
    'concepts',
  );
  static const DataAsset operators = DataAsset(
    'assets/data/operators.json',
    'operators',
  );
}
