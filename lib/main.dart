import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:managment_system/services/authentication.dart';
import 'package:managment_system/views/admin/admin_home.dart';
import 'package:managment_system/views/chef/chef_home.dart';
import 'package:managment_system/views/login.dart';
import 'package:managment_system/views/user/user_home.dart';
import 'package:managment_system/utils/local_storage.dart';
import 'package:managment_system/models/user.dart';
import 'package:managment_system/utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getThemeData(),
      home: const HomeFutureBuilder(),
    );
  }
}

class HomeFutureBuilder extends StatelessWidget {
  const HomeFutureBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    AuthenticationServices authService = AuthenticationServices();
    return FutureBuilder<User?>(
      future: LocalStorage.getToken().then(
          (token) => token != null ? authService.getUserByToken(token) : null),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          User? user = snapshot.data;
          if (user == null) {
            return LoginPage();
          } else {
            if (user.type == 'admin') {
              return AdminHome();
            } else if (user.type == 'chef') {
              return ChefHomeScreen();
            } else {
              return UserHomeScreen();
            }
          }
        }
      },
    );
  }
}
