import 'package:flutter/material.dart';

import '../../common/common.dart';
import 'flash_cards.dart';

class FlashcardsModule extends Module {
  @override
  String get id => 'flashcards';

  @override
  String get label => 'Flashcards';

  @override
  IconData get icon => Icons.style_outlined;

  @override
  IconData get activeIcon => Icons.style;

  @override
  Widget get screen => const FlashcardsScreen();

  @override
  bool get isLearningTool => true;

  @override
  int get priority => 10;

  @override
  Future<void> init() async {
    final cards = await DataLoader.loadList<FlashcardData>(
      path: AppAssets.flashCards.path,
      rootKey: AppAssets.flashCards.rootKey,
      fromJson: (json) => FlashcardData.fromJson(json),
    );
    FlashcardData.init(cards);
  }

  @override
  Color get color => Colors.amber;
}
