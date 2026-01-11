class FlashcardData {
  final String question;
  final String answer;
  final String note;
  final String info;
  final List<String> tags;

  static List<FlashcardData> all = [];

  static void init(List<FlashcardData> cards) {
    all = cards;
  }

  FlashcardData({
    required this.question,
    required this.answer,
    required this.note,
    required this.info,
    required this.tags,
  });

  factory FlashcardData.fromJson(Map<String, dynamic> json) {
    return FlashcardData(
      question: json['question'] as String,
      answer: json['answer'] as String,
      note: json['note'] as String? ?? '',
      info: json['info'] as String? ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
    );
  }
}
