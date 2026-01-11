import 'package:flutter/material.dart';

import '../../common/common.dart';
import 'quiz.dart';

class QuizModule extends Module {
  @override
  String get id => 'quiz';

  @override
  String get label => 'Quiz';

  @override
  IconData get icon => Icons.quiz_outlined;

  @override
  IconData get activeIcon => Icons.quiz_rounded;

  @override
  Widget get screen => const QuizScreen();

  @override
  bool get isLearningTool => true;

  @override
  int get priority => 40;

  @override
  Future<void> init() async {
    final questions = await DataLoader.loadList<QuizQuestion>(
      path: AppAssets.quiz.path,
      rootKey: AppAssets.quiz.rootKey,
      fromJson: (json) => QuizQuestion.fromJson(json),
    );
    QuizQuestion.init(questions);
  }

  @override
  Color get color => Colors.orange;
}
