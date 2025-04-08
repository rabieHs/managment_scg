import 'package:flutter/material.dart';
import 'package:managment_system/models/stock_request.dart';
import 'package:managment_system/services/stock_request_services.dart';
import 'package:managment_system/utils/local_storage.dart'; // For user ID

import '../../models/user.dart';
import '../../services/authentication.dart' show AuthenticationServices;
import 'add_stock_request_screen.dart'; // To navigate to add request screen

class StockRequestListScreen extends StatefulWidget {
  const StockRequestListScreen({Key? key}) : super(key: key);

  @override
  _StockRequestListScreenState createState() => _StockRequestListScreenState();
}

class _StockRequestListScreenState extends State<StockRequestListScreen> {
  final StockRequestService _stockRequestService = StockRequestService();
  final AuthenticationServices _authService = AuthenticationServices();

  List<StockRequest> _stockRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStockRequests();
  }

  Future<void> _loadStockRequests() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // --- Get User ID (Placeholder - Adapt as needed) ---
      String? token = await LocalStorage.getToken();
      print("token: $token");
      User? user = await _authService.getUserByToken(token!); // Example call
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Could not get user ID. Please log in again.')),
        );
        return;
      }
      // --- End Get User ID ---

      _stockRequests =
          await _stockRequestService.getAllStockRequestsForUser(user.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading stock requests: $e')),
      );
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
        title: Text('My Stock Requests'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadStockRequests,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _stockRequests.isEmpty
                ? Center(child: Text('No stock requests found.'))
                : ListView.builder(
                    itemCount: _stockRequests.length,
                    itemBuilder: (context, index) {
                      final request = _stockRequests[index];
                      return ListTile(
                        title: Text('Request for: ${request.stockType}'),
                        subtitle: Text(
                            'Status: ${request.status} | Created: ${request.createdAt}'),
                        trailing: Icon(Icons
                            .arrow_forward_ios), // Example detail indicator
                        // Add onTap for detailed view if needed
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddStockRequestScreen()),
          ).then((_) {
            _loadStockRequests(); // Refresh list after returning from add screen
          });
        },
        label: Text('Request Stock'),
        icon: Icon(Icons.add),
      ),
    );
  }
}
