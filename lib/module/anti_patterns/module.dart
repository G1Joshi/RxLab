import 'package:flutter/material.dart';

import '../../common/common.dart';
import 'anti_patterns.dart';

class AntiPatternsModule extends Module {
  @override
  String get id => 'antipatterns';

  @override
  String get label => 'Anti-patterns';

  @override
  IconData get icon => Icons.warning_amber_outlined;

  @override
  IconData get activeIcon => Icons.warning_rounded;

  @override
  Widget get screen => const AntiPatternsScreen();

  @override
  bool get isLearningTool => true;

  @override
  int get priority => 30;

  @override
  Future<void> init() async {
    final data = await DataLoader.loadList<AntiPatternData>(
      path: AppAssets.antiPatterns.path,
      rootKey: AppAssets.antiPatterns.rootKey,
      fromJson: (json) => AntiPatternData.fromJson(json),
    );
    AntiPatternData.init(data);
  }

  @override
  Color get color => Colors.redAccent;
}
