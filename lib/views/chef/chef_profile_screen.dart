import 'package:flutter/material.dart';
import 'package:managment_system/views/login.dart';
import '../../utils/local_storage.dart';
import '../../services/authentication.dart';
import '../../models/user.dart';

class ChefProfileScreen extends StatefulWidget {
  const ChefProfileScreen({Key? key}) : super(key: key);

  @override
  State<ChefProfileScreen> createState() => _ChefProfileScreenState();
}

class _ChefProfileScreenState extends State<ChefProfileScreen> {
  User? _user;
  final AuthenticationServices _authService = AuthenticationServices();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  _loadUserProfile() async {
    String? token = await LocalStorage.getToken();
    if (token != null) {
      User? user = await _authService.getUserByToken(token);
      if (user != null && user.type == 'chef') {
        setState(() {
          _user = user;
        });
      }
    } else {
      print("token is invalid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chef Profile')),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: <Widget>[
                ListTile(
                  title: const Text('Change Name'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showChangeNameDialog(context);
                  },
                ),
                ListTile(
                  title: const Text('Change Email'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showChangeEmailDialog(context);
                  },
                ),
                ListTile(
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showChangePasswordDialog(context);
                  },
                ),
                ListTile(
                  title: const Text('Logout'),
                  trailing: const Icon(Icons.logout),
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
    );
  }

  Future<void> _showChangeNameDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    _nameController.text = _user?.name ?? '';
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Name'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'New Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your new name';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final String oldPassword = _nameController.text;
                  try {
                    if (_user != null) {
                      User updatedUser = await _authService.updateUserName(
                          _user!.id, _nameController.text);
                      setState(() {
                        _user = updatedUser;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Name updated successfully')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Error updating name: ${e.toString()}')),
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showChangeEmailDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    _emailController.text = _user?.email ?? '';
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Email'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'New Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your new email';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    if (_user != null) {
                      User updatedUser = await _authService.updateUserEmail(
                          _user!.id, _emailController.text);
                      setState(() {
                        _user = updatedUser;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Email updated successfully')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Error updating email: ${e.toString()}')),
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    final _oldPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _oldPasswordController,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Old Password'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your old password';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'New Password'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your new password';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Confirm New Password'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final String oldPassword = _oldPasswordController.text;
                  final String newPassword = _newPasswordController.text;
                  try {
                    if (_user != null) {
                      await _authService.updateUserPassword(
                          _user!.id, oldPassword, newPassword);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Password updated successfully')),
                      );
                      _oldPasswordController.clear();
                      _newPasswordController.clear();
                      _confirmPasswordController.clear();
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Error updating password: ${e.toString()}')),
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to logout?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Logout'),
              onPressed: () async {
                await LocalStorage.saveToken('');
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
