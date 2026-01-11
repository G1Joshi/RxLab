import 'package:flutter/material.dart';

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
    return switch (icon) {
      'search' => Icons.search,
      'check_circle' => Icons.check_circle,
      'refresh' => Icons.refresh,
      'view_list' => Icons.view_list,
      'sync' => Icons.sync,
      'cached' => Icons.cached,
      'undo' => Icons.undo,
      'pan_tool' => Icons.pan_tool,
      _ => Icons.restaurant_menu,
    };
  }

  Color get colorValue {
    return switch (color) {
      'indigo' => Colors.indigo,
      'green' => Colors.green,
      'orange' => Colors.orange,
      'teal' => Colors.teal,
      'blue' => Colors.blue,
      'purple' => Colors.purple,
      'deepPurple' => Colors.deepPurple,
      'pink' => Colors.pink,
      _ => Colors.grey,
    };
  }
}
