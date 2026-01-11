import 'package:flutter/material.dart';

import '../../common/common.dart';
import 'glossary.dart';

class GlossaryModule extends Module {
  @override
  String get id => 'glossary';

  @override
  String get label => 'Glossary';

  @override
  IconData get icon => Icons.menu_book_outlined;

  @override
  IconData get activeIcon => Icons.menu_book_rounded;

  @override
  Widget get screen => const GlossaryScreen();

  @override
  bool get isLearningTool => true;

  @override
  int get priority => 20;

  @override
  Future<void> init() async {
    final terms = await DataLoader.loadList<GlossaryTerm>(
      path: AppAssets.glossary.path,
      rootKey: AppAssets.glossary.rootKey,
      fromJson: (json) => GlossaryTerm.fromJson(json),
    );
    GlossaryTerm.init(terms);
  }

  @override
  Color get color => Colors.teal;
}
