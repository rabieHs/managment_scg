import 'package:flutter/material.dart';
import 'package:managment_system/models/stock_request.dart';
import 'package:managment_system/services/stock_request_services.dart';
import 'package:managment_system/utils/local_storage.dart'; // For user ID
import 'package:managment_system/views/admin/add_stock_screen.dart';

import '../../models/user.dart';
import '../../services/authentication.dart'; // Stock types

class AddStockRequestScreen extends StatefulWidget {
  const AddStockRequestScreen({Key? key}) : super(key: key);

  @override
  _AddStockRequestScreenState createState() => _AddStockRequestScreenState();
}

class _AddStockRequestScreenState extends State<AddStockRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedStockType;
  final TextEditingController _descriptionController = TextEditingController();
  final AuthenticationServices _authService = AuthenticationServices();

  // Reusing stock types from admin add stock screen
  // Stock types - copied from AddStockScreen for consistency
  final List<String> _stockTypes = [
    'monitor',
    'keyboard',
    'printers',
    'software',
    'peripherique',
    'cartouche de limpriment',
    'Baies',
    'network',
    'computers'
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // --- Get User ID ---
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

      final now = DateTime.now();
      StockRequest newRequest = StockRequest(
        senderId: user.id,
        stockType: _selectedStockType!,
        description: _descriptionController.text,
        createdAt: now,
      );

      try {
        await StockRequestService().addStockRequest(newRequest);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stock request submitted successfully')),
        );
        // Clear form
        _descriptionController.clear();
        setState(() {
          _selectedStockType = null; // Reset dropdown
        });
        _formKey.currentState!.reset();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to submit stock request: ${error.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Stock Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedStockType,
                decoration: InputDecoration(
                  labelText: 'Stock Type',
                  border: OutlineInputBorder(),
                ),
                items: _stockTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Please select stock type' : null,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStockType = newValue;
                  });
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
