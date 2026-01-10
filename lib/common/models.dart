import 'package:flutter/material.dart';

import 'theme.dart';

class MarbleItem {
  final dynamic value;
  final double time;
  final Color? color;
  final bool isError;
  final bool isComplete;

  const MarbleItem({
    required this.value,
    required this.time,
    this.color,
    this.isError = false,
    this.isComplete = false,
  });

  Color get displayColor {
    if (isError) return Colors.red;
    if (isComplete) return AppTheme.textMuted;
    if (color != null) return color!;

    if (value is int) {
      return AppTheme.getMarbleColor(value as int);
    }
    return AppTheme.marbleColors[value.hashCode % AppTheme.marbleColors.length];
  }

  MarbleItem copyWith({
    dynamic value,
    double? time,
    Color? color,
    bool? isError,
    bool? isComplete,
  }) {
    return MarbleItem(
      value: value ?? this.value,
      time: time ?? this.time,
      color: color ?? this.color,
      isError: isError ?? this.isError,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  String toString() => 'MarbleItem($value @ $time)';
}

class MarbleStream {
  final String label;
  final List<MarbleItem> items;
  final bool hasError;
  final bool isComplete;

  const MarbleStream({
    this.label = '',
    this.items = const [],
    this.hasError = false,
    this.isComplete = true,
  });

  factory MarbleStream.fromValues(List<dynamic> values, {String label = ''}) {
    if (values.isEmpty) return MarbleStream(label: label);

    final items = values.asMap().entries.map((entry) {
      final time = (entry.key + 1) / (values.length + 1);
      return MarbleItem(value: entry.value, time: time);
    }).toList();

    return MarbleStream(label: label, items: items, isComplete: true);
  }

  factory MarbleStream.withTimes(
    List<MapEntry<dynamic, double>> valuesWithTimes, {
    String label = '',
  }) {
    final items = valuesWithTimes
        .map((e) => MarbleItem(value: e.key, time: e.value))
        .toList();
    return MarbleStream(label: label, items: items, isComplete: true);
  }

  List<MarbleItem> get sortedItems {
    final sorted = List<MarbleItem>.from(items);
    sorted.sort((a, b) => a.time.compareTo(b.time));
    return sorted;
  }

  MarbleStream copyWith({
    String? label,
    List<MarbleItem>? items,
    bool? hasError,
    bool? isComplete,
  }) {
    return MarbleStream(
      label: label ?? this.label,
      items: items ?? this.items,
      hasError: hasError ?? this.hasError,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

enum OperatorCategory {
  creation('Creation', 'Create new streams'),
  transformation('Transformation', 'Transform emitted values'),
  filtering('Filtering', 'Filter or limit emissions'),
  combination('Combination', 'Combine multiple streams'),
  errorHandling('Error Handling', 'Handle stream errors'),
  utility('Utility', 'Utility operations on streams');

  final String displayName;
  final String description;

  const OperatorCategory(this.displayName, this.description);
  static OperatorCategory parse(String value) {
    return switch (value.toLowerCase()) {
      'creation' => OperatorCategory.creation,
      'transformation' => OperatorCategory.transformation,
      'filtering' => OperatorCategory.filtering,
      'combination' => OperatorCategory.combination,
      'error_handling' => OperatorCategory.errorHandling,
      'utility' => OperatorCategory.utility,
      _ => OperatorCategory.utility,
    };
  }
}

typedef OperatorExecutor = MarbleStream Function(List<MarbleStream> inputs);

class OperatorDefinition {
  final String name;
  final String description;
  final OperatorCategory category;
  final List<MarbleStream> defaultInputs;
  final OperatorExecutor executor;
  final String codeExample;
  final String? detailedDescription;

  const OperatorDefinition({
    required this.name,
    this.description = '',
    this.category = OperatorCategory.utility,
    this.defaultInputs = const [],
    required this.executor,
    this.codeExample = '',
    this.detailedDescription,
  });

  factory OperatorDefinition.fromJson(Map<String, dynamic> json) {
    return OperatorDefinition(
      name: json['name'] as String,
      description: json['description'] as String,
      detailedDescription: json['detailedDescription'] as String?,
      category: OperatorCategory.parse(json['category'] as String),
      codeExample: json['codeExample'] as String,
      executor: (inputs) => inputs.first,
      defaultInputs: [],
    );
  }

  OperatorDefinition copyWith({
    String? name,
    String? description,
    OperatorCategory? category,
    List<MarbleStream>? defaultInputs,
    OperatorExecutor? executor,
    String? codeExample,
    String? detailedDescription,
  }) {
    return OperatorDefinition(
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      defaultInputs: defaultInputs ?? this.defaultInputs,
      executor: executor ?? this.executor,
      codeExample: codeExample ?? this.codeExample,
      detailedDescription: detailedDescription ?? this.detailedDescription,
    );
  }

  MarbleStream execute(List<MarbleStream> inputs) => executor(inputs);

  IconData get icon {
    switch (category) {
      case OperatorCategory.creation:
        return Icons.add_circle_outline;
      case OperatorCategory.transformation:
        return Icons.transform;
      case OperatorCategory.filtering:
        return Icons.filter_alt;
      case OperatorCategory.combination:
        return Icons.merge;
      case OperatorCategory.errorHandling:
        return Icons.healing;
      case OperatorCategory.utility:
        return Icons.build;
    }
  }

  Color get categoryColor {
    switch (category) {
      case OperatorCategory.creation:
        return Colors.green;
      case OperatorCategory.transformation:
        return AppTheme.marbleColors[0];
      case OperatorCategory.filtering:
        return AppTheme.marbleColors[1];
      case OperatorCategory.combination:
        return AppTheme.marbleColors[6];
      case OperatorCategory.errorHandling:
        return Colors.red;
      case OperatorCategory.utility:
        return AppTheme.marbleColors[7];
    }
  }
}
