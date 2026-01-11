class PowerSets {
  static List<PowerSetOperator> all = [];

  static void init(List<PowerSetOperator> metadata) {
    all = metadata;
  }

  static List<PowerSetOperator> search(String query) {
    final lowercaseQuery = query.toLowerCase();
    return all
        .where(
          (op) =>
              op.name.toLowerCase().contains(lowercaseQuery) ||
              (op.description?.toLowerCase().contains(lowercaseQuery) ?? false),
        )
        .toList();
  }
}

class PowerSetOperator {
  final String name;
  final bool isCanonical;
  final String? description;
  final String? icon;
  final String? color;

  PowerSetOperator({
    required this.name,
    required this.isCanonical,
    this.description,
    this.icon,
    this.color,
  });

  factory PowerSetOperator.fromJson(Map<String, dynamic> json) {
    return PowerSetOperator(
      name: json['name'] as String,
      isCanonical: json['isCanonical'] as bool? ?? false,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }
}
