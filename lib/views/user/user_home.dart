import 'package:flutter/material.dart';
import 'package:managment_system/views/user/question_screen.dart';

import '../admin/admin_profile_screen.dart';
import 'stock_request_list_screen.dart'; // Import StockRequestListScreen

class UserHomeScreen extends StatefulWidget {
  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    QuestionScreen(),
    StockRequestListScreen(), // Stock Request List Screen here
    AdminProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Home'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.question_mark), // Changed to question_mark icon
            label: 'Questions', // Changed label to Questions
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
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
