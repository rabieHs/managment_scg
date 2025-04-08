import '../models/user.dart';
import '../utils/connection.dart';

class UserService {
  // Get user by id
  Future<User?> getUserById(int id) async {
    final connection = await Connection.createConnection();
    // Query users table for any type of user by ID
    String query = 'SELECT * FROM users WHERE id = ?';
    try {
      final results = await connection.query(query, [id]);
      if (results.isNotEmpty) {
        final row = results.first.fields!;
        // Use the User.fromJson factory to create a User object
        return User.fromJson(row);
      } else {
        print('getUserById: User not found for ID $id');
        return null; // User not found
      }
    } catch (e) {
      print('getUserById: Error fetching user by ID $id: $e');
      return null; // Error fetching user
    } finally {
      await connection.close();
    }
  }

  // Add other user-related methods here if needed in the future
}
