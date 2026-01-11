import 'package:flutter/material.dart';

import '../../../common/common.dart';

class QuizQuestion {
  final String type;
  final String category;
  final String difficulty;
  final int points;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  final String? input;
  final String? operator;

  final String? code;

  static List<QuizQuestion> all = [];

  static void init(List<QuizQuestion> questions) {
    all = questions;
  }

  QuizQuestion({
    required this.type,
    required this.category,
    required this.difficulty,
    required this.points,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.input,
    this.operator,
    this.code,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      type: json['type'] as String? ?? 'multiple_choice',
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      points: json['points'] as int? ?? 10,
      question: json['question'] as String,
      options: List<String>.from(json['options'] ?? json['answers'] ?? []),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String,
      input: json['input'] as String?,
      operator: json['operator'] as String?,
      code: json['code'] as String?,
    );
  }

  Color get categoryColor {
    return Utils.getCategoryColor(category);
  }

  Color get difficultyColor {
    return Utils.getCategoryColor(difficulty);
  }

  IconData get typeIcon {
    return Utils.getCategoryIcon(type);
  }
}
