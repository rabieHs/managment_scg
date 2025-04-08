import 'package:flutter/material.dart';
import '../../services/question_services.dart'; // Import QuestionService
import '../../models/question.dart'; // Import Question Model
import '../../utils/local_storage.dart'; // Import LocalStorage
import 'question_detail_screen.dart'; // Import QuestionDetailScreen

class QuestionScreen extends StatefulWidget {
  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final TextEditingController _questionController = TextEditingController();
  String _response = '';
  String _questionType = '';
  bool _isLoading = false;
  final QuestionService _questionService = QuestionService();
  List<Question> _userQuestions = []; // Use Question model for list

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'replied':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserQuestions(); // Load questions when screen initializes
  }

  Future<void> _loadUserQuestions() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _userQuestions = await _questionService.getChefSpecialityQuestions();
    } catch (e) {
      // Handle error loading questions
      print('Error loading questions: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _askQuestion() async {
    setState(() {
      _isLoading = true;
      _response = '';
      _questionType = '';
    });

    final questionText = _questionController.text;

    try {
      final question = await _questionService
          .askQuestion(questionText); // Returns Question object
      setState(() {
        _questionType = question.type ?? 'Unknown Type'; // Handle nullable type
        _response = question.aiResponse;
      });
      // Upload question to database after getting AI response (already done in service)
      _questionController
          .clear(); // Clear the question input field after successful submission
      _loadUserQuestions(); // Reload questions after asking a new one
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questions'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuestionBottomSheet,
        child: Icon(Icons.add),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _userQuestions.length,
                      itemBuilder: (context, index) {
                        final question = _userQuestions[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              // Use InkWell for tap effect
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuestionDetailScreen(
                                        question:
                                            question), // Navigate to detail screen
                                  ),
                                );
                              },
                              child: ListTile(
                                title: Text('Q: ${question.question}',
                                    style: TextStyle(
                                        fontWeight: FontWeight
                                            .bold)), // Use Question properties
                                subtitle: Row(
                                  // Use Row for status color
                                  children: [
                                    Text(
                                        'Type: ${question.type ?? 'Unknown Type'}, Status: '), // Type text
                                    Container(
                                      // Status color indicator
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                            question.status), // Color by status
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(question.status,
                                          style: TextStyle(
                                              color:
                                                  Colors.white)), // Status text
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_response.isNotEmpty) ...[
                    // Conditionally show response
                    SizedBox(height: 20),
                    Text('AI Response for last question:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Type: $_questionType'),
                    SingleChildScrollView(child: Text(_response)),
                  ],
                ],
              ),
            ),
    );
  }

  void _showQuestionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the bottom sheet to take up the full screen height
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom), // Adjust padding when keyboard appears
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Make bottom sheet size to its content
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Ask a Question",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    labelText: 'Your Question',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _askQuestion();
                    Navigator.pop(
                        context); // Close bottom sheet after asking question
                  },
                  child: Text('Ask'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
