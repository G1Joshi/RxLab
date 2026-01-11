import 'package:flutter/material.dart';

import '../../common/common.dart';
import 'wizard.dart';

class WizardModule extends Module {
  @override
  String get id => 'wizard';

  @override
  String get label => 'Wizard';

  @override
  IconData get icon => Icons.auto_awesome_outlined;

  @override
  IconData get activeIcon => Icons.auto_awesome;

  @override
  Widget get screen => const WizardScreen();

  @override
  bool get isLearningTool => true;

  @override
  int get priority => 50;

  @override
  Future<void> init() async {
    final decisionData = await DataLoader.loadMap(
      path: AppAssets.decisionTree.path,
    );
    final decisionRoot = decisionData != null
        ? DecisionTreeNode.fromJson(
            decisionData[AppAssets.decisionTree.rootKey],
          )
        : null;

    final categories = await DataLoader.loadList<CheatSheetCategory>(
      path: AppAssets.cheatSheet.path,
      rootKey: AppAssets.cheatSheet.rootKey,
      fromJson: (json) => CheatSheetCategory.fromJson(json),
    );

    CheatSheetCategory.init(categories);
    DecisionTreeNode.init(decisionRoot);
  }

  @override
  Color get color => Colors.amber;
}
