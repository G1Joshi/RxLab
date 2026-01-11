import 'package:flutter/material.dart';

import '../../common/common.dart';

class AntiPatternData {
  final String title;
  final String description;
  final String icon;
  final String color;
  final int severity;
  final List<String> relatedOperators;
  final String tip;
  final String wrongCode;
  final String rightCode;
  final String explanation;

  static List<AntiPatternData> all = [];

  static void init(List<AntiPatternData> data) {
    all = data..sort((a, b) => b.severity.compareTo(a.severity));
  }

  AntiPatternData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.severity,
    required this.relatedOperators,
    required this.tip,
    required this.wrongCode,
    required this.rightCode,
    required this.explanation,
  });

  factory AntiPatternData.fromJson(Map<String, dynamic> json) {
    return AntiPatternData(
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      severity: json['severity'] as int,
      relatedOperators: List<String>.from(json['relatedOperators']),
      tip: json['tip'] as String,
      wrongCode: json['wrongCode'] as String,
      rightCode: json['rightCode'] as String,
      explanation: json['explanation'] as String,
    );
  }

  IconData get iconData {
    return Utils.getIcon(icon, fallback: Icons.warning);
  }

  Color get colorValue {
    return Utils.getColor(color);
  }
}
