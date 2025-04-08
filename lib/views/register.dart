import 'package:flutter/material.dart';
import '../services/authentication.dart';
import '../models/user.dart';
import '../views/user/user_home.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final AuthenticationServices _authService = AuthenticationServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name')),
                TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email')),
                TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password')),
                TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone')),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final User newUser = User(
                        id: 0,
                        name: _nameController.text,
                        email: _emailController.text,
                        type: 'user', // Default user type for registration
                        phone: _phoneController.text,
                      );
                      final String password = _passwordController.text;
                      try {
                        final User? registeredUser =
                            await _authService.registerUser(newUser, password);
                        if (registeredUser != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Registration successful.')),
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserHomeScreen()),
                            (route) => false,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Registration failed')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Error during registration: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
