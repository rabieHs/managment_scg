import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:managment_system/models/stock.dart';
import 'package:managment_system/services/stock_services.dart';
// Removed LocalStorage import as userId is not set here

class AddStockScreen extends StatefulWidget {
  const AddStockScreen({Key? key}) : super(key: key);

  @override
  _AddStockScreenState createState() => _AddStockScreenState();
}

class _AddStockScreenState extends State<AddStockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _modelController = TextEditingController();
  String _selectedType = 'monitor';
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
    _nameController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Removed user ID fetching logic

      final now = DateTime.now();
      Stock newStock = Stock(
        name: _nameController.text,
        type: _selectedType,
        manufacturer: _manufacturerController.text,
        model: _modelController.text,
        // status and location will use defaults defined in the model
        // userId will be null by default as it's optional in constructor now
        creationDate: now,
        updateDate: now,
      );

      try {
        await StockService().addStock(newStock);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stock item added successfully')),
        );
        // Clear the form fields after successful submission
        _nameController.clear();
        _manufacturerController.clear();
        _modelController.clear();
        setState(() {
          _selectedType = 'monitor';
        });
        _formKey.currentState!.reset();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to add stock item: ${error.toString()}')), // Show error details
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Stock'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            // Added for scrolling if content overflows
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Stock Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter stock name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10), // Adjusted spacing
                TextFormField(
                  // New field for Manufacturer
                  controller: _manufacturerController,
                  decoration: InputDecoration(labelText: 'Manufacturer'),
                  // Add validator if needed, e.g., cannot be empty
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter manufacturer';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10), // Adjusted spacing
                TextFormField(
                  // New field for Model
                  controller: _modelController,
                  decoration: InputDecoration(labelText: 'Model'),
                  // Add validator if needed, e.g., cannot be empty
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter model';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(labelText: 'Stock Type'),
                  items: _stockTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedType = newValue!;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select stock type' : null,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Add Stock'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
