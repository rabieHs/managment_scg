import 'package:flutter/material.dart';
import 'package:managment_system/models/question.dart';

class QuestionDetailScreen extends StatelessWidget {
  final Question question;

  QuestionDetailScreen({required this.question});

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
              Text('Question:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(question.question, style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              Text('Type:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(question.type ?? 'Unknown'),
              SizedBox(height: 20),
              ExpansionTile(
                title: Text('AI Response:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(question.aiResponse),
                  ),
                ],
              ),
              ExpansionTile(
                title: Text('Chef Response:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(question.chefResponse ?? 'Not yet replied'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Status:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getStatusColor(question.status),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(question.status,
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
