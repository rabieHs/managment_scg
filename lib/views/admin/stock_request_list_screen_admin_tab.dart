import 'package:flutter/material.dart';
import '../../services/stock_request_services.dart';
import '../../models/stock_request.dart';
import 'stock_request_detail_screen_admin.dart'; // Import detail screen

class StockRequestListScreenAdminTab extends StatefulWidget {
  const StockRequestListScreenAdminTab({Key? key}) : super(key: key);

  @override
  _StockRequestListScreenAdminTabState createState() =>
      _StockRequestListScreenAdminTabState();
}

class _StockRequestListScreenAdminTabState
    extends State<StockRequestListScreenAdminTab> {
  final StockRequestService _stockRequestService = StockRequestService();
  List<StockRequest> _requests = [];
  bool _isLoading = false; // Add loading indicator

  @override
  void initState() {
    super.initState();
    _loadStockRequests();
  }

  _loadStockRequests() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    try {
      final requests = await _stockRequestService.getAllStockRequestsForAdmin();
      setState(() {
        _requests = requests;
      });
    } catch (e) {
      print("Error loading stock requests: $e");
      // Consider showing a more user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load stock requests: \$e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // End loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator()) // Loading indicator
        : _requests.isEmpty
            ? const Center(child: Text('No stock requests yet.'))
            : ListView.builder(
                itemCount: _requests.length,
                itemBuilder: (context, index) {
                  final request = _requests[index];
                  return ListTile(
                    title: Text('Request ID: ${request.id}'),
                    subtitle: Text(
                        'Type: ${request.stockType}, Status: ${request.status}'),
                    trailing: Icon(
                        Icons.arrow_forward_ios), // Visual cue for tap action
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StockRequestDetailScreenAdmin(
                            requestId: request.id!,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
  }
}
