import 'package:flutter/material.dart';
import 'package:managment_system/services/question_services.dart';
import 'package:managment_system/models/question.dart';
import 'chef_profile_screen.dart';
import 'question_detail_screen.dart';
import '../user/stock_request_list_screen.dart'; // Import StockRequestListScreen

class ChefHomeScreen extends StatefulWidget {
  const ChefHomeScreen({Key? key}) : super(key: key);

  @override
  _ChefHomeScreenState createState() => _ChefHomeScreenState();
}

class _ChefHomeScreenState extends State<ChefHomeScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    _buildHomeBody(), // Home body (questions list)
    StockRequestListScreen(), // Stock Request List Screen here
    ChefProfileScreen(), // Chef Profile Screen
  ];

  Widget _getBody() {
    return _widgetOptions[_selectedIndex];
  }

  static Widget _buildHomeBody() {
    // Made static to avoid instance member issues
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Welcome Chef!',
            style: TextStyle(fontSize: 20),
          ),
          Expanded(
            child: FutureBuilder<List<Question>>(
              future: QuestionService().getChefSpecialityQuestions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return _buildQuestionList(
                      snapshot.data!); // Use static method
                } else {
                  return const Center(child: Text('No questions found'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildQuestionList(List<Question> questions) {
    // Made static
    return ListView.builder(
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChefQuestionDetailScreen(question: question),
                ),
              );
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      question.question,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Type: ${question.type}',
                        style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status: ${question.status}',
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: question.status == 'pending'
                                    ? Colors.orange
                                    : Colors.green)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chef Home'),
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2), // Inventory icon
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.amber[800],
      ),
    );
  }
}
