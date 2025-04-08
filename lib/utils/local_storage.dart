import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static Future<void> saveToken(String token) async {
    // Save the token to the local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    // Get the token from the local storage
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveUserId(int userId) async {
    // Save the user ID to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    print("saved user id ${userId}");
  }

  static Future<int?> getUserId() async {
    // Get the user ID from local storage
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }
}
