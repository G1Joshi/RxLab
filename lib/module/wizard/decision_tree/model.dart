class DecisionTreeNode {
  final String question;
  final List<DecisionTreeNode>? options;
  final String? operator;
  final String? description;

  static DecisionTreeNode? root;

  static void init(DecisionTreeNode? node) {
    root = node;
  }

  const DecisionTreeNode({
    required this.question,
    this.options,
    this.operator,
    this.description,
  });

  bool get isResult => operator != null;

  factory DecisionTreeNode.fromJson(Map<String, dynamic> json) {
    return DecisionTreeNode(
      question: json['question'] as String,
      operator: json['operator'] as String?,
      description: json['description'] as String?,
      options: json['options'] != null
          ? (json['options'] as List)
                .map(
                  (i) => DecisionTreeNode.fromJson(i as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }
}
