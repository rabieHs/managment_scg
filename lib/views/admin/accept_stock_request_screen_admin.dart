import 'package:flutter/material.dart';
import '../../services/stock_services.dart';
import '../../services/stock_request_services.dart';
import '../../models/stock.dart';
import '../../models/stock_request.dart';
import '../../models/user.dart'; // Assuming you need User model for assigning user_id

class AcceptStockRequestScreenAdmin extends StatefulWidget {
  final int requestId;

  const AcceptStockRequestScreenAdmin({Key? key, required this.requestId})
      : super(key: key);

  @override
  _AcceptStockRequestScreenAdminState createState() =>
      _AcceptStockRequestScreenAdminState();
}

class _AcceptStockRequestScreenAdminState
    extends State<AcceptStockRequestScreenAdmin> {
  final StockService _stockService = StockService();
  final StockRequestService _stockRequestService = StockRequestService();
  StockRequest? _stockRequest;
  List<Stock> _availableStockItems = [];
  Stock? _selectedStockItem;
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
      _stockRequest =
          await _stockRequestService.getStockRequestById(widget.requestId);
      if (_stockRequest != null) {
        _availableStockItems =
            await _stockService.getStocksByType(_stockRequest!.stockType);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: \$error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptRequest() async {
    if (_selectedStockItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a stock item')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      if (_stockRequest == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stock request not loaded properly.')),
        );
        return;
      }
      await _stockService.updateStockItem(
        _selectedStockItem!.id,
        userId: _stockRequest!.senderId, // Assign to the user who requested
        status: 'active',
      );
      await _stockRequestService.updateStockRequestStatus(
          widget.requestId, 'accepted');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request Accepted and Stock Updated')),
      );
      Navigator.pop(context); // Go back to request list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept request: \$error')),
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
        title: Text('Accept Stock Request'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _stockRequest == null
              ? Center(child: Text('Request details not loaded'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Request Type: ${_stockRequest!.stockType}'),
                      SizedBox(height: 20),
                      DropdownButtonFormField<Stock>(
                        value: _selectedStockItem,
                        hint: Text('Select Stock Item'),
                        items: _availableStockItems.map((Stock stock) {
                          return DropdownMenuItem<Stock>(
                            value: stock,
                            child: Text(stock.name),
                          );
                        }).toList(),
                        onChanged: (Stock? newValue) {
                          setState(() {
                            _selectedStockItem = newValue;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Available Stock Items',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null ? 'Please select a stock item' : null,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed:
                            _selectedStockItem == null ? null : _acceptRequest,
                        child: Text('Accept Request'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
