import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../../models/stock_request.dart';
import 'accept_stock_request_screen_admin.dart'; // Import AcceptStockRequestScreenAdmin
import '../../services/stock_request_services.dart';

class StockRequestDetailScreenAdmin extends StatefulWidget {
  final int requestId;

  const StockRequestDetailScreenAdmin({Key? key, required this.requestId})
      : super(key: key);

  @override
  State<StockRequestDetailScreenAdmin> createState() =>
      _StockRequestDetailScreenAdminState();
}

class _StockRequestDetailScreenAdminState
    extends State<StockRequestDetailScreenAdmin> {
  final StockRequestService _stockRequestService = StockRequestService();
  StockRequest? _stockRequest;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequestDetails();
  }

  Future<void> _loadRequestDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<StockRequest> requests =
          await _stockRequestService.getAllStockRequestsForAdmin();
      try {
        _stockRequest =
            requests.firstWhere((req) => req.id == widget.requestId);
      } catch (e) {
        // Catch error if no element is found
        _stockRequest = null;
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load request details: \$error')),
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
        title: Text('Request Detail'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _stockRequest == null
              ? Center(child: Text('Request not found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Request ID: ${widget.requestId}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('Stock Type: ${_stockRequest?.stockType ?? 'N/A'}'),
                      SizedBox(height: 10),
                      Text('Status: ${_stockRequest?.status ?? 'N/A'}'),
                      SizedBox(height: 20),
                      // Display Stock Type and Status here
                      // You can add more details here if needed
                      Text(
                          'Requested by User ID: ${_stockRequest?.senderId ?? 'N/A'}'),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AcceptStockRequestScreenAdmin(
                                    requestId: widget.requestId,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Accept'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                await _stockRequestService
                                    .updateStockRequestStatus(
                                        widget.requestId, 'rejected');
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Request Rejected successfully!')),
                                );
                              } catch (error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Failed to reject request: \$error')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text('Reject'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
