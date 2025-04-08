import 'package:managment_system/models/chef.dart';
import 'package:managment_system/utils/connection.dart';
import '../utils/encrypption.dart';

class ChefServices {
  //Create a new chef
  Future<Chef> createChef(Chef chef) async {
    final connection = await Connection.createConnection();
    final _encrptedPassword = Encrypption.hashPassword(chef.password);
    String query = '''
      INSERT INTO users(name,email,password,type,phone,speciality) VALUES(?,?,?,?,?,?)
    ''';
    var result = await connection.query(query, [
      chef.name,
      chef.email,
      _encrptedPassword,
      'chef',
      chef.phone,
      chef.speciality
          .join(','), // Store specialities as comma-separated string in DB
    ]);
    if (result.insertId != null) {
      return chef.copyWith(id: result.insertId);
    } else {
      throw Exception('Chef not created');
    }
  }

  //Get chefs list
  Future<List<Chef>> getChefs() async {
    final connection = await Connection.createConnection();
    String query = '''
      SELECT * FROM users WHERE type = ?
    ''';
    var results = await connection.query(query, ['chef']);
    List<Chef> chefs = [];
    for (var row in results) {
      chefs.add(fromJson(row.fields!));
    }
    return chefs;
  }

  Chef fromJson(Map<String, dynamic> json) {
    return Chef(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      phone: json['phone'],
      speciality: (json['speciality'] as String).split(','),
    );
  }

  //Update chef
  Future<Chef> updateChef(Chef chef) async {
    final connection = await Connection.createConnection();
    String query = '''
      UPDATE users SET name = ?, email = ?, phone = ?, speciality = ? WHERE id = ?
    ''';
    await connection.query(query, [
      chef.name,
      chef.email,
      chef.phone,
      chef.speciality.join(','), // Update with comma-separated string
      chef.id,
    ]);
    return chef;
  }

  //Delete chef
  Future<void> deleteChef(int id) async {
    final connection = await Connection.createConnection();
    String query = '''
      DELETE FROM users WHERE id = ?
    ''';
    await connection.query(query, [id]);
  }

  //Get chef by id
  Future<Chef?> getChefById(String id) async {
    final connection = await Connection.createConnection();
    String query = 'SELECT * FROM users WHERE id = ?';
    try {
      final results = await connection.query(query, [id]);
      if (results.isNotEmpty) {
        final row = results.first.fields!;
        return fromJson(row);
      } else {
        return null; // Stock not found
      }
    } catch (e) {
      print('getChefById: Error fetching chef item by ID $id: $e');
      return null; // Error fetching stock
    } finally {
      await connection.close();
    }
  }
}
