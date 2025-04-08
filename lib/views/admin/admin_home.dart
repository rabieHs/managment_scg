import 'package:flutter/material.dart';

import '../chef/chef_home.dart';
import 'chefs_screen.dart';
import 'admin_profile_screen.dart';
import 'qr_code_scanner_screen.dart';
import 'stock_list_screen.dart';
import 'stock_request_list_screen_admin_tab.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 2;
  static List<Widget> _widgetOptions = <Widget>[
    const QRCodeScannerScreen(),
    ChefsScreen(),
    StockListScreen(),
    StockRequestListScreenAdminTab(),
    const AdminProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = 2; // Initialize to Stock & Requests tab
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home'),
        actions: <Widget>[],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'QR Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Chefs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
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
