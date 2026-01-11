import 'package:flutter/material.dart';

import '../../common/utils.dart';

class RecipeData {
  final String title;
  final String description;
  final String icon;
  final String color;
  final String problem;
  final String solution;
  final List<String> operatorsUsed;
  final String codeExample;

  static List<RecipeData> all = [];

  static void init(List<RecipeData> recipes) {
    all = recipes;
  }

  RecipeData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.problem,
    required this.solution,
    required this.operatorsUsed,
    required this.codeExample,
  });

  factory RecipeData.fromJson(Map<String, dynamic> json) {
    return RecipeData(
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      problem: json['problem'] as String,
      solution: json['solution'] as String,
      operatorsUsed: List<String>.from(json['operatorsUsed']),
      codeExample: json['codeExample'] as String,
    );
  }

  IconData get iconData {
    return Utils.getIcon(icon, fallback: Icons.restaurant_menu);
  }

  Color get colorValue {
    return Utils.getColor(color);
  }
}
