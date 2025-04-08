class Question {
  final int id;
  final int senderId;
  final String question;
  final String? type; // Change type to String? (nullable String)
  final String aiResponse;
  final String status;
  final String? chefResponse;

  Question({
    required this.id,
    required this.senderId,
    required this.question,
    required this.type, // type is now nullable
    required this.aiResponse,
    required this.status,
    this.chefResponse, // Make chefResponse optional
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      senderId: json['sender_id'],
      question: json['question'],
      type: json['type'], // type is now nullable
      aiResponse: json['ai_response']?.toString() ??
          'Error loading response', // Handle potential null and convert to String
      status: json['status'],
      chefResponse: json['chef_response']
          ?.toString(), // Ensure chefResponse is String and handle null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'question': question,
      'type': type,
      'ai_response': aiResponse,
      'status': status,
      'chef_response': chefResponse, // Include chefResponse in toJson
    };
  }
}
