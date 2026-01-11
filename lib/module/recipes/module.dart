import 'package:flutter/material.dart';

import '../../common/common.dart';
import 'recipes.dart';

class RecipesModule extends Module {
  @override
  String get id => 'recipes';

  @override
  String get label => 'Recipes';

  @override
  IconData get icon => Icons.menu_book_outlined;

  @override
  IconData get activeIcon => Icons.menu_book;

  @override
  Widget get screen => const RecipesScreen();

  @override
  bool get isLearningTool => true;

  @override
  int get priority => 60;

  @override
  Future<void> init() async {
    final recipes = await DataLoader.loadList<RecipeData>(
      path: AppAssets.recipes.path,
      rootKey: AppAssets.recipes.rootKey,
      fromJson: (json) => RecipeData.fromJson(json),
    );
    RecipeData.init(recipes);
  }
}
