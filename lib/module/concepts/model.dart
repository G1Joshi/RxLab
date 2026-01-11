import 'package:flutter/material.dart';

import '../../common/common.dart';

class ConceptData {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String color;
  final String description;
  final List<String> keyPoints;
  final String codeExample;

  static List<ConceptData> all = [];

  static void init(List<ConceptData> data) {
    all = data;
  }

  ConceptData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.description,
    required this.keyPoints,
    required this.codeExample,
  });

  factory ConceptData.fromJson(Map<String, dynamic> json) {
    return ConceptData(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      description: json['description'] as String,
      keyPoints: List<String>.from(json['keyPoints']),
      codeExample: json['codeExample'] as String,
    );
  }

  IconData get iconData {
    return Utils.getIcon(icon, fallback: Icons.school);
  }

  Color get colorValue {
    return Utils.getColor(color);
  }
}
