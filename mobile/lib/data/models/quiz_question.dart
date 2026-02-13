class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.nodeId,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String id;
  final String nodeId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  factory QuizQuestion.fromMap(String id, Map<String, dynamic> map) {
    final List<dynamic> rawOptions =
        map['options'] as List<dynamic>? ?? <dynamic>[];
    return QuizQuestion(
      id: id,
      nodeId: map['nodeId'] as String? ?? '',
      question: map['question'] as String? ?? '',
      options: rawOptions.map((dynamic e) => e.toString()).toList(),
      correctIndex: map['correctIndex'] as int? ?? 0,
      explanation: map['explanation'] as String? ?? '',
    );
  }
}
