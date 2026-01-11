import 'package:flutter/material.dart';

import '../../common/common.dart';

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
    return Utils.getCategoryColor(category);
  }

  IconData get categoryIcon {
    return Utils.getCategoryIcon(category);
  }
}
