import 'package:flutter/material.dart';

import '../../common/common.dart';
import 'concepts.dart';

class ConceptsModule extends Module {
  @override
  String get id => 'concepts';

  @override
  String get label => 'Learn';

  @override
  IconData get icon => Icons.school_outlined;

  @override
  IconData get activeIcon => Icons.school_rounded;

  @override
  Widget get screen => const ConceptsScreen();

  @override
  bool get isTopLevel => true;

  @override
  int get priority => 90;

  @override
  Future<void> init() async {
    final data = await DataLoader.loadList<ConceptData>(
      path: AppAssets.concepts.path,
      rootKey: AppAssets.concepts.rootKey,
      fromJson: (json) => ConceptData.fromJson(json),
    );
    ConceptData.init(data);
  }

  @override
  Color get color => Colors.purple;
}
