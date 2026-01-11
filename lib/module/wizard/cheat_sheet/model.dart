import 'package:flutter/material.dart';

class CheatSheetCategory {
  final String title;
  final String icon;
  final String color;
  final List<CheatSheetOperator> operators;

  static List<CheatSheetCategory> all = [];

  static void init(List<CheatSheetCategory> categories) {
    all = categories;
  }

  CheatSheetCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.operators,
  });

  factory CheatSheetCategory.fromJson(Map<String, dynamic> json) {
    return CheatSheetCategory(
      title: json['title'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      operators: (json['operators'] as List)
          .map((op) => CheatSheetOperator.fromJson(op as Map<String, dynamic>))
          .toList(),
    );
  }

  Color get colorValue {
    return switch (color) {
      'green' => Colors.green,
      'blue' => Colors.blue,
      'purple' => Colors.purple,
      'orange' => Colors.orange,
      'teal' => Colors.teal,
      'red' => Colors.red,
      'grey' => Colors.grey,
      'indigo' => Colors.indigo,
      _ => Colors.grey,
    };
  }

  IconData get iconData {
    return switch (icon) {
      'add_circle' => Icons.add_circle,
      'transform' => Icons.transform,
      'filter_list' => Icons.filter_list,
      'speed' => Icons.speed,
      'merge_type' => Icons.merge_type,
      'healing' => Icons.healing,
      'build' => Icons.build,
      'hourglass_empty' => Icons.hourglass_empty,
      _ => Icons.help,
    };
  }
}

class CheatSheetOperator {
  final String name;
  final String oneLiner;

  CheatSheetOperator({required this.name, required this.oneLiner});

  factory CheatSheetOperator.fromJson(Map<String, dynamic> json) {
    return CheatSheetOperator(
      name: json['name'] as String,
      oneLiner: json['oneLiner'] as String,
    );
  }
}
