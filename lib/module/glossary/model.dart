import 'package:flutter/material.dart';

class GlossaryTerm {
  final String term;
  final String definition;
  final String category;
  final List<String> relatedTerms;
  final String example;

  static List<GlossaryTerm> all = [];

  static void init(List<GlossaryTerm> terms) {
    all = terms..sort((a, b) => a.term.compareTo(b.term));
  }

  GlossaryTerm({
    required this.term,
    required this.definition,
    required this.category,
    required this.relatedTerms,
    required this.example,
  });

  factory GlossaryTerm.fromJson(Map<String, dynamic> json) {
    return GlossaryTerm(
      term: json['term'] as String,
      definition: json['definition'] as String,
      category: json['category'] as String,
      relatedTerms: (json['relatedTerms'] as List).cast<String>(),
      example: json['example'] as String,
    );
  }

  Color get categoryColor {
    return switch (category) {
      'Core' => Colors.blue,
      'Subjects' => Colors.purple,
      'Concepts' => Colors.teal,
      'Operators' => Colors.orange,
      'Transformation' => Colors.indigo,
      'Filtering' => Colors.green,
      'Combination' => Colors.cyan,
      'Aggregate' => Colors.amber,
      'Conditional' => Colors.deepOrange,
      'Error Handling' => Colors.red,
      'Utility' => Colors.blueGrey,
      'Connectable' => Colors.pink,
      'Creation' => Colors.lime,
      'Conversion' => Colors.brown,
      'Advanced' => Colors.deepPurple,
      'Patterns' => Colors.green,
      'Problems' => Colors.red,
      _ => Colors.grey,
    };
  }

  IconData get categoryIcon {
    return switch (category) {
      'Core' => Icons.hub,
      'Subjects' => Icons.send,
      'Concepts' => Icons.lightbulb,
      'Operators' => Icons.build,
      'Transformation' => Icons.transform,
      'Filtering' => Icons.filter_alt,
      'Combination' => Icons.merge,
      'Aggregate' => Icons.functions,
      'Conditional' => Icons.alt_route,
      'Error Handling' => Icons.error,
      'Utility' => Icons.settings,
      'Connectable' => Icons.power,
      'Creation' => Icons.add_circle,
      'Conversion' => Icons.sync,
      'Advanced' => Icons.psychology,
      'Patterns' => Icons.pattern,
      'Problems' => Icons.warning,
      _ => Icons.help,
    };
  }
}
