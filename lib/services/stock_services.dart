import '../models/stock.dart'; // Import Stock model
import '../utils/connection.dart'; // Import Connection

class StockService {
  StockService() {
    _initializeTable(); // Initialize stock table on service construction
  }

  _initializeTable() async {
    final connection = await Connection.createConnection();
    // Initialize the stock table if it doesn't exist
    // Note: This only runs if the table doesn't exist. Existing tables won't be altered.
    // Manual ALTER TABLE might be needed for existing deployments.
    String query = '''
      CREATE TABLE IF NOT EXISTS stock (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        type VARCHAR(255) NOT NULL,
        manufacturer VARCHAR(255),
        model VARCHAR(255),
        status VARCHAR(255) NOT NULL DEFAULT 'available',
        location VARCHAR(255) DEFAULT 'SCG',
        creation_date DATETIME NOT NULL,
        update_date DATETIME NOT NULL,
        user_id INT NULL -- Allow NULL for user_id
      );
    ''';
    try {
      await connection.query(query);
      print('_initializeTable: Stock table checked/created successfully.');
    } catch (e) {
      print('_initializeTable: Error initializing stock table: $e');
      // Decide if you want to re-throw or handle differently
    } finally {
      await connection.close();
    }
  }

  Future<void> addStock(Stock stock) async {
    final connection = await Connection.createConnection();
    // Use current time for creation and update on adding
    final now = DateTime.now();
    String query = '''
      INSERT INTO stock(name, type, manufacturer, model, status, location, creation_date, update_date, user_id)
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''';
    try {
      await connection.query(query, [
        stock.name,
        stock.type,
        stock.manufacturer,
        stock.model,
        stock.status,
        stock.location,
        now.toUtc(),
        now.toUtc(),
        null,
      ]);
      print(
          'addStock: Stock item ${stock.name} added successfully (userId initially null)');
    } catch (e) {
      print('addStock: Error adding stock item ${stock.name}: $e');
      throw Exception('Failed to add stock item: $e');
    } finally {
      await connection.close();
    }
  }

  Future<void> updateStockItem(
    int? stockId, {
    int? userId,
    String? status,
  }) async {
    if (stockId == null) {
      throw Exception('Stock ID is required for updating status or user.');
    }

    final connection = await Connection.createConnection();
    String query = '''
      UPDATE stock
      SET 
        update_date = NOW(),
        status = COALESCE(?, status),
        user_id = COALESCE(?, user_id)
      WHERE id = ?
    ''';
    try {
      await connection.query(query, [
        status,
        userId,
        stockId,
      ]);
      print(
          'updateStockItem: Stock item ID $stockId updated with status=$status, userId=$userId');
    } catch (e) {
      print('updateStockItem: Error updating stock item ID $stockId: $e');
      throw Exception('Failed to update stock item: $e');
    } finally {
      await connection.close();
    }
  }

  Future<void> updateStock(Stock stock) async {
    if (stock.id == null) {
      throw Exception('Cannot update stock item without an ID.');
    }
    final connection = await Connection.createConnection();
    final now = DateTime.now();
    String query = '''
      UPDATE stock
      SET name = ?, type = ?, manufacturer = ?, model = ?, status = ?, location = ?, update_date = ?, user_id = ?
      WHERE id = ?
    ''';
    try {
      await connection.query(query, [
        stock.name,
        stock.type,
        stock.manufacturer,
        stock.model,
        stock.status,
        stock.location,
        now.toUtc(), // Convert to UTC
        stock.userId, // Pass the potentially null userId for update
        stock.id, // Use the ID in the WHERE clause
      ]);
      print('updateStock: Stock item ID ${stock.id} updated successfully');
    } catch (e) {
      print('updateStock: Error updating stock item ID ${stock.id}: $e');
      throw Exception('Failed to update stock item: $e');
    } finally {
      await connection.close();
    }
  }

  Future<List<Stock>> getAllStock() async {
    final connection = await Connection.createConnection();
    String query =
        'SELECT * FROM stock ORDER BY creation_date DESC'; // Order by newest first
    List<Stock> stockList = [];
    try {
      final results = await connection.query(query);
      for (final row in results) {
        // Manually map row data to Stock object fields
        stockList.add(Stock(
          id: row[0] as int?, // Assuming id is the first column (index 0)
          name: row[1] as String? ??
              '', // Assuming name is the second column (index 1)
          type: row[2] as String? ??
              '', // Assuming type is the third column (index 2)
          manufacturer: row[3] as String? ??
              '', // Assuming manufacturer is the fourth column (index 3)
          model: row[4] as String? ??
              '', // Assuming model is the fifth column (index 4)
          status: row[5] as String? ??
              'available', // Assuming status is the sixth column (index 5)
          location: row[6] as String? ??
              'SCG', // Assuming location is the seventh column (index 6)
          creationDate: row[7] != null
              ? (row[7] as DateTime).toLocal()
              : DateTime
                  .now(), // Assuming creation_date is the eighth column (index 7), convert back to local
          updateDate: row[8] != null
              ? (row[8] as DateTime).toLocal()
              : DateTime
                  .now(), // Assuming update_date is the ninth column (index 8), convert back to local
          userId:
              row[9] as int?, // Assuming user_id is the tenth column (index 9)
        ));
      }
      print(
          'getAllStock: Fetched ${stockList.length} stock items successfully.');
    } catch (e) {
      print('getAllStock: Error fetching stock items: $e');
      // Consider returning an empty list or re-throwing
    } finally {
      await connection.close();
    }
    return stockList;
  }

  Future<List<Stock>> getStocksByType(String stockType) async {
    final connection = await Connection.createConnection();
    String query = '''
      SELECT * FROM stock
      WHERE type = ? AND status = 'available'
      ORDER BY creation_date DESC
    ''';
    List<Stock> stockList = [];
    try {
      final results = await connection.query(query, [stockType]);
      for (final row in results) {
        stockList.add(Stock(
          id: row[0] as int?,
          name: row[1] as String? ?? '',
          type: row[2] as String? ?? '',
          manufacturer: row[3] as String? ?? '',
          model: row[4] as String? ?? '',
          status: row[5] as String? ?? 'available',
          location: row[6] as String? ?? 'SCG',
          creationDate: (row[7] as DateTime).toLocal(),
          updateDate: (row[8] as DateTime).toLocal(),
          userId: row[9] as int?,
        ));
      }
      print(
          'getStocksByType: Fetched ${stockList.length} stock items of type $stockType.');
    } catch (e) {
      print(
          'getStocksByType: Error fetching stock items of type $stockType: $e');
    } finally {
      await connection.close();
    }
    return stockList;
  }

  Future<Stock?> getStockById(String id) async {
    final connection = await Connection.createConnection();
    String query = 'SELECT * FROM stock WHERE id = ?';
    try {
      final results = await connection.query(query, [id]);
      if (results.isNotEmpty) {
        final row = results.first.fields!;
        return Stock(
          id: row['id'] as int?,
          name: row['name'] as String? ?? '',
          type: row['type'] as String? ?? '',
          manufacturer: row['manufacturer'] as String? ?? '',
          model: row['model'] as String? ?? '',
          status: row['status'] as String? ?? 'available',
          location: row['location'] as String? ?? 'SCG',
          creationDate: row['creation_date'] != null
              ? (row['creation_date'] as DateTime).toLocal()
              : DateTime.now(),
          updateDate: row['update_date'] != null
              ? (row['update_date'] as DateTime).toLocal()
              : DateTime.now(),
          userId: row['user_id'] as int?,
        );
      } else {
        return null; // Stock not found
      }
    } catch (e) {
      print('getStockById: Error fetching stock item by ID $id: $e');
      return null; // Error fetching stock
    } finally {
      await connection.close();
    }
  }
}
