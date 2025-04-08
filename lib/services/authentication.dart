import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:managment_system/models/user.dart';
import 'package:managment_system/utils/connection.dart';
import 'package:managment_system/utils/local_storage.dart';

import '../utils/encrypption.dart';

class AuthenticationServices {
  // Database instance

  AuthenticationServices() {
    _initializeTable();
    _initializeSessions();
  }

  _initializeTable() async {
    final connection = await Connection.createConnection();
    // Initialize the table
    String query = '''
     CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    type VARCHAR(100),
    phone VARCHAR(20),
    speciality VARCHAR(255)
);
    ''';
    await connection.query(query);
  }

  _initializeSessions() async {
    final connection = await Connection.createConnection();
    // Initialize the table
    String query = '''
 CREATE TABLE IF NOT EXISTS sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    expires_at DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
    ''';
    await connection.query(query);
  }

  // Login a user

  Future<User> loginUser(String email, String password) async {
    final connection = await Connection.createConnection();
    final _encrptedPassword = Encrypption.hashPassword(password);
    String query = '''
    SELECT * FROM users WHERE email = ? AND password = ?
    ''';

    var results = await connection.query(query, [email, _encrptedPassword]);
    if (results.isEmpty) {
      throw Exception('Invalid email or password');
    }

    final user = User.fromJson(results.first.fields);
    final token = Encrypption.generateToken(user.id);
    String session_query = '''
      INSERT INTO sessions(user_id,session_token,expires_at) VALUES(?,?,DATE_ADD(NOW(), INTERVAL 1 HOUR))
      ''';
    await connection.query(session_query, [user.id, token]);
    await LocalStorage.saveToken(token);
    await LocalStorage.saveUserId(user.id);

    await connection.close();
    return user;
  }

  // Register a new user
  Future<User> registerUser(User user, String password) async {
    final connection = await Connection.createConnection();

    final _encrptedPassword = Encrypption.hashPassword(password);
    String query = '''
  INSERT INTO users(name,email,password,type,phone,speciality) VALUES(?,?,?,?,?,?)
   ''';
    var result = await connection.query(query, [
      user.name,
      user.email,
      _encrptedPassword,
      user.type,
      user.phone,
      user.speciality?.join(',') ?? '',
    ]);

    final id = result.insertId;
    if (id != null) {
      final token = Encrypption.generateToken(id);

      String query = '''
      INSERT INTO sessions(user_id,session_token,expires_at) VALUES(?,?,DATE_ADD(NOW(), INTERVAL 1 HOUR))
      ''';
      await connection.query(query, [id, token]);
      await LocalStorage.saveToken(token);
      await connection.close();
      return user.copyWith(id: id);
    } else {
      await connection.close();
      throw Exception('User not created');
    }
  }

  // Get a user by session token

  Future<User?> getUserByToken(String token) async {
    final connection = await Connection.createConnection();
    String query = '''
    SELECT * FROM users JOIN sessions ON users.id = sessions.user_id WHERE session_token = ? AND sessions.expires_at > NOW()
    ''';
    var results = await connection.query(query, [token]);
    print("result: $results");
    if (results.isEmpty) {
      return null;
    }
    final user = User.fromJson(results.first.fields);
    await connection.close();
    return user;
  }

  Future<User> updateUserName(int userId, String newName) async {
    final connection = await Connection.createConnection();
    String query = '''
    UPDATE users SET name = ? WHERE id = ?
    ''';
    await connection.query(query, [newName, userId]);
    String selectQuery = '''
    SELECT * FROM users WHERE id = ?
    ''';
    var results = await connection.query(selectQuery, [userId]);
    await connection.close();
    return User.fromJson(results.first.fields);
  }

  Future<User> updateUserEmail(int userId, String newEmail) async {
    final connection = await Connection.createConnection();
    String query = '''
    UPDATE users SET email = ? WHERE id = ?
    ''';
    await connection.query(query, [newEmail, userId]);
    String selectQuery = '''
    SELECT * FROM users WHERE id = ?
    ''';
    var results = await connection.query(selectQuery, [userId]);
    await connection.close();
    return User.fromJson(results.first.fields);
  }

  Future<User> updateUserPassword(
      int userId, String oldPassword, String newPassword) async {
    final connection = await Connection.createConnection();
    final _encrptedPassword = Encrypption.hashPassword(oldPassword);

    String verifyQuery = '''
    SELECT * FROM users WHERE id = ? AND password = ?
    ''';
    var verifyResult =
        await connection.query(verifyQuery, [userId, _encrptedPassword]);
    if (verifyResult.isEmpty) {
      throw Exception('Invalid old password');
    }

    final _newEncrptedPassword = Encrypption.hashPassword(newPassword);
    String query = '''
    UPDATE users SET password = ? WHERE id = ?
    ''';
    await connection.query(query, [_newEncrptedPassword, userId]);
    String selectQuery = '''
    SELECT * FROM users WHERE id = ?
    ''';
    var results = await connection.query(selectQuery, [userId]);
    await connection.close();
    return User.fromJson(results.first.fields);
  }
}
