import 'package:flutter/material.dart';
import 'package:managment_system/models/chef.dart';
import 'package:managment_system/services/chef_services.dart';
import 'package:managment_system/utils/consts.dart';

class AddChefScreen extends StatefulWidget {
  const AddChefScreen({Key? key}) : super(key: key);

  @override
  _AddChefScreenState createState() => _AddChefScreenState();
}

class _AddChefScreenState extends State<AddChefScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final List<String> selectedSpecialitiesList = [];
  final ChefServices _chefService = ChefServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Chef')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter chef name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter chef email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter chef password';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter chef phone';
                    }
                    return null;
                  },
                ),
                FormField<List<String>>(
                  initialValue: [],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select chef specialities';
                    }
                    return null;
                  },
                  builder: (FormFieldState<List<String>> state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Specialities',
                            errorText: state.errorText,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          child: SizedBox(
                            height: 150,
                            child: ListView.builder(
                              itemCount: specialities.length,
                              itemBuilder: (BuildContext context, int index) {
                                return CheckboxListTile(
                                  title: Text(specialities[index]),
                                  value: selectedSpecialitiesList
                                      .contains(specialities[index]),
                                  onChanged: (bool? newValue) {
                                    if (newValue == true) {
                                      setState(() {
                                        selectedSpecialitiesList
                                            .add(specialities[index]);
                                      });
                                    } else {
                                      setState(() {
                                        selectedSpecialitiesList
                                            .remove(specialities[index]);
                                      });
                                    }
                                    state.didChange(selectedSpecialitiesList);
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final Chef newChef = Chef(
                        id: 0,
                        name: _nameController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                        phone: _phoneController.text,
                        speciality: selectedSpecialitiesList,
                      );
                      try {
                        await _chefService.createChef(newChef);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Chef created successfully')),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Error creating chef: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  child: const Text('Add Chef'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
