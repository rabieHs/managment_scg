import 'package:flutter/material.dart';
import 'package:managment_system/models/stock.dart';
import 'package:managment_system/services/stock_services.dart';
import 'package:managment_system/views/admin/add_stock_screen.dart'; // To navigate

class StockListScreen extends StatefulWidget {
  const StockListScreen({Key? key}) : super(key: key);

  @override
  _StockListScreenState createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  final StockService _stockService = StockService();
  List<Stock> _allStockItems = [];
  List<Stock> _filteredStockItems = [];
  bool _isLoading = true;
  String? _selectedFilterType; // Null means 'All'
  final TextEditingController _searchQueryController = TextEditingController();

  // Reusing the types from AddStockScreen, plus 'All'
  final List<String?> _stockTypesFilter = [
    null, // Represents 'All'
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
  void initState() {
    super.initState();
    _fetchStockItems();
    _searchQueryController.addListener(_filterStockList);
  }

  @override
  void dispose() {
    _searchQueryController.removeListener(_filterStockList);
    _searchQueryController.dispose();
    super.dispose();
  }

  Future<void> _fetchStockItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _allStockItems = await _stockService.getAllStock();
      _filteredStockItems = _allStockItems; // Initially show all
    } catch (e) {
      // Handle error, maybe show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching stock items: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterStockList() {
    final query = _searchQueryController.text.toLowerCase();
    setState(() {
      _filteredStockItems = _allStockItems.where((stock) {
        final typeMatches =
            _selectedFilterType == null || stock.type == _selectedFilterType;
        final queryMatches = query.isEmpty ||
            stock.name.toLowerCase().contains(query) ||
            stock.manufacturer.toLowerCase().contains(query) ||
            stock.model.toLowerCase().contains(query);
        return typeMatches && queryMatches;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock List'),
      ),
      body: RefreshIndicator(
        // Added RefreshIndicator
        onRefresh: _fetchStockItems, // Call fetch on pull-to-refresh
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchQueryController,
                decoration: InputDecoration(
                  labelText: 'Search by Name, Manufacturer, Model',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                // onChanged handled by listener
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: DropdownButtonFormField<String?>(
                value: _selectedFilterType,
                decoration: InputDecoration(
                  labelText: 'Filter by Type',
                  border: OutlineInputBorder(),
                ),
                items: _stockTypesFilter.map((String? type) {
                  return DropdownMenuItem<String?>(
                    value: type,
                    child: Text(
                        type ?? 'All Types'), // Display 'All Types' for null
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFilterType = newValue;
                    _filterStockList(); // Re-filter when type changes
                  });
                },
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _filteredStockItems.isEmpty
                      ? Center(child: Text('No stock items found.'))
                      : ListView.builder(
                          itemCount: _filteredStockItems.length,
                          itemBuilder: (context, index) {
                            final stock = _filteredStockItems[index];
                            return ListTile(
                              title: Text(stock.name),
                              subtitle: Text(
                                  'Type: ${stock.type} | Manufacturer: ${stock.manufacturer} | Model: ${stock.model} | Status: ${stock.status}'),
                              // Add onTap for potential detail view or edit later
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to AddStockScreen and refresh list when returning
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddStockScreen()),
          );
          // Optional: Refresh list if AddStockScreen indicates success
          // For simplicity, we always refresh here after returning.
          _fetchStockItems();
        },
        icon: Icon(Icons.add),
        label: Text('Add Stock'),
      ),
    );
  }
}
