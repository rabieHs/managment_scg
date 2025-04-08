import '../models/stock_request.dart';
import '../utils/connection.dart';

class StockRequestService {
  StockRequestService() {
    _initializeRequestTable();
  }

  _initializeRequestTable() async {
    final connection = await Connection.createConnection();
    String query = '''
      CREATE TABLE IF NOT EXISTS stock_requests (
        id INT AUTO_INCREMENT PRIMARY KEY,
        sender_id INT NOT NULL,
        stock_type VARCHAR(255) NOT NULL,
        status VARCHAR(255) NOT NULL DEFAULT 'pending',
        description TEXT,
        created_at DATETIME NOT NULL
      );
    ''';
    try {
      await connection.query(query);
      print('_initializeRequestTable: Stock request table checked/created.');
    } catch (e) {
      print(
          '_initializeRequestTable: Error initializing stock request table: $e');
    } finally {
      await connection.close();
    }
  }

  Future<void> addStockRequest(StockRequest request) async {
    final connection = await Connection.createConnection();
    final now = DateTime.now();
    String query = '''
      INSERT INTO stock_requests(sender_id, stock_type, status, description, created_at)
      VALUES(?, ?, ?, ?, ?)
    ''';
    try {
      await connection.query(query, [
        request.senderId,
        request.stockType,
        request.status,
        request.description,
        now.toUtc(), // Store creation time in UTC
      ]);
      print('addStockRequest: Stock request added successfully.');
    } catch (e) {
      print('addStockRequest: Error adding stock request: $e');
      throw Exception('Failed to add stock request: $e');
    } finally {
      await connection.close();
    }
  }

  Future<List<StockRequest>> getAllStockRequestsForUser(int userId) async {
    final connection = await Connection.createConnection();
    String query = '''
      SELECT * FROM stock_requests 
      WHERE sender_id = ?
      ORDER BY created_at DESC
    ''';
    List<StockRequest> requests = [];
    try {
      final results = await connection.query(query, [userId]);
      for (final row in results) {
        print('Row: $row'); // Print the entire row for inspection
        print('Type of row[2] (stockType): ${row[2].runtimeType}');
        print('Type of row[3] (status): ${row[3].runtimeType}');
        print('Type of row[4] (description): ${row[4].runtimeType}');
        requests.add(StockRequest(
          id: row[0] as int?,
          senderId: row[1] as int,
          stockType: row[2].toString(),
          status: row[3].toString(),
          description: row[4].toString(),
          createdAt:
              (row[5] as DateTime).toLocal(), // Convert back to local time
        ));
      }
      print(
          'getAllStockRequestsForUser: Fetched ${requests.length} requests for user $userId.');
    } catch (e) {
      print(
          'getAllStockRequestsForUser: Error fetching requests for user $userId: $e');
    } finally {
      await connection.close();
    }
    return requests;
  }

  Future<StockRequest?> getStockRequestById(int requestId) async {
    final connection = await Connection.createConnection();
    String query = '''
      SELECT * FROM stock_requests
      WHERE id = ?
    ''';
    try {
      final results = await connection.query(query, [requestId]);
      if (results.isNotEmpty) {
        final row = results.first;
        return StockRequest(
          id: row[0] as int?,
          senderId: row[1] as int,
          stockType: row[2].toString(),
          status: row[3].toString(),
          description: row[4].toString(),
          createdAt: (row[5] as DateTime).toLocal(),
        );
      }
      return null; // Request not found
    } catch (e) {
      print('getStockRequestById: Error fetching request by ID: $e');
      return null;
    } finally {
      await connection.close();
    }
  }

  Future<List<StockRequest>> getAllStockRequestsForAdmin() async {
    final connection = await Connection.createConnection();
    String query = '''
      SELECT * FROM stock_requests
      ORDER BY created_at DESC
    ''';
    List<StockRequest> requests = [];
    try {
      final results = await connection.query(query);
      for (final row in results) {
        requests.add(StockRequest(
          id: row[0] as int?,
          senderId: row[1] as int,
          stockType: row[2].toString(),
          status: row[3].toString(),
          description: row[4].toString(),
          createdAt: (row[5] as DateTime).toLocal(),
        ));
      }
      print(
          'getAllStockRequestsForAdmin: Fetched ${requests.length} requests for admin.');
    } catch (e) {
      print(
          'getAllStockRequestsForAdmin: Error fetching requests for admin: $e');
    } finally {
      await connection.close();
    }
    return requests;
  }

  Future<void> updateStockRequestStatus(int requestId, String status) async {
    final connection = await Connection.createConnection();
    String query = '''
      UPDATE stock_requests
      SET status = ?
      WHERE id = ?
    ''';
    try {
      await connection.query(query, [status, requestId]);
      print(
          'updateStockRequestStatus: Stock request $requestId status updated to $status.');
    } catch (e) {
      print(
          'updateStockRequestStatus: Error updating stock request $requestId status: $e');
      throw Exception('Failed to update stock request status: $e');
    } finally {
      await connection.close();
    }
  }
}
