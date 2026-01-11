import 'package:flutter/material.dart';

import '../../../common/common.dart';

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
    return Utils.getColor(color);
  }

  IconData get iconData {
    return Utils.getIcon(icon);
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
