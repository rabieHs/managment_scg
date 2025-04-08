import 'package:flutter/material.dart';
import 'package:managment_system/models/question.dart';
import 'package:managment_system/services/question_services.dart';

class ChefQuestionDetailScreen extends StatefulWidget {
  final Question question;

  const ChefQuestionDetailScreen({Key? key, required this.question})
      : super(key: key);

  @override
  _ChefQuestionDetailScreenState createState() =>
      _ChefQuestionDetailScreenState();
}

class _ChefQuestionDetailScreenState extends State<ChefQuestionDetailScreen> {
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Question: ${widget.question.question}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('Type: ${widget.question.type}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text('Status: ${widget.question.status}',
                  style: TextStyle(
                      fontSize: 16,
                      color: widget.question.status == 'closed'
                          ? Colors.green
                          : Colors.black)),
              SizedBox(height: 10),
              ExpansionTile(
                title: Text('AI Response', style: TextStyle(fontSize: 16)),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('${widget.question.aiResponse}',
                        style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
              if (widget.question.chefResponse != null &&
                  widget.question.chefResponse!.isNotEmpty)
                ExpansionTile(
                  title: Text('My Response', style: TextStyle(fontSize: 16)),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('${widget.question.chefResponse}',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              SizedBox(height: 20),
              TextFormField(
                controller: _answerController,
                decoration: InputDecoration(
                  labelText: 'Your Answer',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _submitAnswer(context);
                },
                child: Text('Submit Answer'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _closeQuestion(context);
                },
                child: Text('Close Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitAnswer(BuildContext context) async {
    String chefResponse = _answerController.text;
    if (chefResponse.isNotEmpty) {
      try {
        await QuestionService().answerQuestion(
          widget.question.id,
          chefResponse,
        );
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit answer')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your answer')),
      );
    }
  }

  void _closeQuestion(BuildContext context) async {
    try {
      await QuestionService().closeQuestion(widget.question.id);
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to close question')),
      );
    }
  }
}
