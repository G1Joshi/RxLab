class DataAsset {
  final String path;
  final String rootKey;
  const DataAsset(this.path, this.rootKey);
}

class AppAssets {
  static const DataAsset antiPatterns = DataAsset(
    'assets/data/antiPatterns.json',
    'antiPatterns',
  );
  static const DataAsset cheatSheet = DataAsset(
    'assets/data/cheatSheet.json',
    'cheatSheet',
  );
  static const DataAsset concepts = DataAsset(
    'assets/data/concepts.json',
    'concepts',
  );
  static const DataAsset decisionTree = DataAsset(
    'assets/data/decisionTree.json',
    'decisionTree',
  );
  static const DataAsset flashCards = DataAsset(
    'assets/data/flashCards.json',
    'flashCards',
  );
  static const DataAsset glossary = DataAsset(
    'assets/data/glossary.json',
    'glossary',
  );
  static const DataAsset operators = DataAsset(
    'assets/data/operators.json',
    'operators',
  );
  static const DataAsset powerSet = DataAsset(
    'assets/data/powerSet.json',
    'operators',
  );
  static const DataAsset quiz = DataAsset('assets/data/quiz.json', 'quiz');
  static const DataAsset recipes = DataAsset(
    'assets/data/recipes.json',
    'recipes',
  );
}
