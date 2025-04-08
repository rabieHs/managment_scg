import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/question.dart'; // Import Question model
import '../utils/local_storage.dart'; // Import LocalStorage
import '../utils/connection.dart'; // Import Connection
import '../models/user.dart'; // Import User model (for senderId)
import '../services/authentication.dart'; // Import AuthenticationServices
import 'package:mysql1/mysql1.dart'; // Import Blob class from mysql1

class QuestionService {
  QuestionService() {
    _initializeTable(); // Initialize questions table on service construction
  }

  _initializeTable() async {
    final connection = await Connection.createConnection();
    // Initialize the questions table if it doesn't exist
    String query = '''
     CREATE TABLE IF NOT EXISTS questions (
      id INT AUTO_INCREMENT PRIMARY KEY,
      sender_id INT NOT NULL, 
      question TEXT NOT NULL,
      type VARCHAR(255) NOT NULL,
      ai_response TEXT NOT NULL,
      chef_response TEXT,
      status VARCHAR(255) NOT NULL,
      FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE -- Assuming users table exists
    );
    ''';
    await connection.query(query);
    await connection.close();
  }

  Future<Question> askQuestion(String questionText) async {
    final url = Uri.parse('http://localhost:3000/ask_question');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'question': questionText}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final questionType = responseData['type'];
      final aiResponse = responseData['ai_response'];

      // After getting AI response, upload question to local database
      User? user = await _getCurrentUser(); // Get current user
      if (user != null) {
        final questionToUpload = Question(
          id: 0, // Auto-incremented by database
          senderId: user.id,
          question: questionText,
          type: questionType, // Use extracted type
          aiResponse: aiResponse, // Use extracted aiResponse
          chefResponse: null, // Initially null
          status: 'pending',
        );
        print(
            'askQuestion: questionToUpload.senderId: ${questionToUpload.senderId}'); // Log senderId
        await uploadQuestionToDatabase(questionToUpload);
        return questionToUpload;
      } else {
        throw Exception(
            'User not logged in'); // Handle case where user is not logged in
      }
    } else {
      throw Exception('Failed to ask question: ${response.statusCode}');
    }
  }

  Future<List<Question>> getChefSpecialityQuestions() async {
    final connection = await Connection.createConnection();
    User? user = await _getCurrentUser(); // Get current user
    if (user == null) {
      throw Exception('User not logged in');
    }
    if (user.type != 'chef') {
      throw Exception('Not a chef user');
    }
    final chefSpecialities =
        (user.speciality ?? []).map((s) => s.trim()).toList();
    if (chefSpecialities.isEmpty) {
      return []; // Return empty list if no specialities defined
    }

    // Construct IN clause for MySQL query
    final placeholders =
        List.generate(chefSpecialities.length, (_) => '?').join(',');
    String query = '''
      SELECT * FROM questions WHERE type IN ($placeholders)
    ''';

    final results = await connection.query(query, chefSpecialities);
    await connection.close();
    return results.map((row) {
      final fields = row.fields;
      // Convert Blob values to Strings explicitly using toString()
      final convertedFields = fields.map((key, value) {
        if (value is Blob) {
          return MapEntry(key, value.toString()); // Use toString() on Blob
        }
        return MapEntry(key, value);
      });
      return Question.fromJson(convertedFields);
    }).toList();
  }

  Future<void> uploadQuestionToDatabase(Question question) async {
    final connection = await Connection.createConnection();
    String query = '''
      INSERT INTO questions(sender_id, question, type, ai_response, chef_response, status) 
      VALUES(?, ?, ?, ?, ?, ?)
    ''';
    try {
      print(
          'uploadQuestionToDatabase: Query: $query, Parameters: ${question.toJson()}'); // Log query and params
      await connection.query(query, [
        question.senderId,
        question.question,
        question.type,
        question.aiResponse,
        question.chefResponse,
        question.status,
      ]);
      print(
          'uploadQuestionToDatabase: Question saved successfully'); // Log success
    } catch (e) {
      print('uploadQuestionToDatabase: Error saving question: $e'); // Log error
    } finally {
      await connection.close();
    }
    print('Question data uploaded to database: ${question.toJson()}');
  }

  Future<User?> _getCurrentUser() async {
    final token = await LocalStorage.getToken();
    if (token == null) {
      print(
          '_getCurrentUser: No token found in LocalStorage'); // Log if no token
      return null;
    }
    print(
        '_getCurrentUser: Token from LocalStorage: $token'); // Log token value
    try {
      final authService = AuthenticationServices();
      final user = await authService.getUserByToken(token);
      print(
          '_getCurrentUser: User ID from token: ${user?.id}'); // Log user ID - VERIFY USER ID
      return user; // VERIFY RETURNING USER OBJECT
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<void> answerQuestion(int questionId, String chefResponse) async {
    final connection = await Connection.createConnection();
    String query = '''
      UPDATE questions 
      SET chef_response = ?, status = ?
      WHERE id = ?
    ''';
    try {
      await connection.query(query, [chefResponse, 'closed', questionId]);
      print('answerQuestion: Question $questionId answered successfully');
    } catch (e) {
      print('answerQuestion: Error answering question $questionId: $e');
      throw Exception('Failed to answer question: $e');
    } finally {
      await connection.close();
    }
  }

  Future<void> closeQuestion(int questionId) async {
    final connection = await Connection.createConnection();
    String query = '''
      UPDATE questions 
      SET status = ?
      WHERE id = ?
    ''';
    try {
      await connection.query(query, ['closed', questionId]);
      print('closeQuestion: Question $questionId closed successfully');
    } catch (e) {
      print('closeQuestion: Error closing question $questionId: $e');
      throw Exception('Failed to close question: $e');
    } finally {
      await connection.close();
    }
  }
}
