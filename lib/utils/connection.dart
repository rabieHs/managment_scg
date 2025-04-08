import 'package:mysql1/mysql1.dart';

class Connection {
  static Future<MySqlConnection> createConnection() async {
    var settings = ConnectionSettings(
        host: '192.168.1.123', port: 3306, user: 'root', db: 'system_managemt');
    return await MySqlConnection.connect(settings);
  }
}
